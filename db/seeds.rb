require 'open-uri'
require 'csv'
require 'zip'
require 'set'

# [TODO] - Move this complex logic to a Model (Service) with the help with a Rake Task if it's used more than once.

data_url = 'https://assets.benny.ai/code-test/heart-rate-monitor/data.zip'

tmp_dir = Rails.root.join('tmp')
FileUtils.mkdir_p(tmp_dir)
zip_path = tmp_dir.join('data.zip')

puts "Downloading data from #{data_url}..."
begin
  URI.open(data_url) do |remote_file|
    File.open(zip_path, 'wb') do |file|
      file.write(remote_file.read)
    end
  end
  puts "Download completed successfully"
rescue => e
  puts "Error downloading file: #{e.message}"
  raise
end

extracted_path = tmp_dir.join('data')
FileUtils.mkdir_p(extracted_path)

puts "Extracting files..."
begin
  Zip::File.open(zip_path) do |zip_file|
    zip_file.each do |entry|
      entry.extract(File.join(extracted_path, entry.name)) { true }
    end
  end
  puts "Extraction completed successfully"
rescue => e
  puts "Error extracting files: #{e.message}"
  raise
end

users_csv       = File.join(extracted_path, 'users.csv')
sessions_csv    = File.join(extracted_path, 'hrm_sessions.csv')
data_points_csv = File.join(extracted_path, 'hrm_data_points.csv')

# Verify files exist
puts "Checking files..."
[ users_csv, sessions_csv, data_points_csv ].each do |file|
  if File.exist?(file)
    puts "Found #{file}"
    puts "File size: #{File.size(file)} bytes"
  else
    puts "Missing #{file}"
    raise "Required file not found: #{file}"
  end
end

BATCH_SIZE = 20_000

ActiveRecord::Base.transaction do
  puts "Importing users..."
  user_count = 0
  CSV.foreach(users_csv, headers: true).each_slice(BATCH_SIZE) do |rows|
    user_count += rows.size
    User.upsert_all(
      rows.map do |row|
        {
          id: row['User ID'].to_i,
          created_at: row['Created At'],
          username: row['Username'],
          gender: row['Gender'],
          age: row['Age'].to_i,
          hr_zone1_bpm_min: row['HR Zone1 BPM Min'].to_i,
          hr_zone1_bpm_max: row['HR Zone1 BPM Max'].to_i,
          hr_zone2_bpm_min: row['HR Zone2 BPM Min'].to_i,
          hr_zone2_bpm_max: row['HR Zone2 BPM Max'].to_i,
          hr_zone3_bpm_min: row['HR Zone3 BPM Min'].to_i,
          hr_zone3_bpm_max: row['HR Zone3 BPM Max'].to_i,
          hr_zone4_bpm_min: row['HR Zone4 BPM Min'].to_i,
          hr_zone4_bpm_max: row['HR Zone4 BPM Max'].to_i
        }
      end,
      unique_by: :id
    )
    puts "Imported #{user_count} users..."
  end

  puts "Importing HRM sessions..."
  session_count = 0
  CSV.foreach(sessions_csv, headers: true).each_slice(BATCH_SIZE) do |rows|
    valid_rows = rows.reject { |row| row['User Id'].to_i.zero? }
    next if valid_rows.empty?

    session_count += valid_rows.size
    HrmSession.upsert_all(
      valid_rows.map do |row|
        {
          id: row['Session ID'].to_i,
          user_id: row['User Id'].to_i,
          created_at: row['Created At'],
          duration_in_secs: row['Duration in Secs'].to_i
        }
      end,
      unique_by: :id
    )
    puts "Imported #{session_count} sessions..."
  end

  puts "Importing HRM data points..."
  data_point_count = 0
  valid_session_ids = HrmSession.pluck(:id).to_set

  CSV.foreach(data_points_csv, headers: true).each_slice(BATCH_SIZE) do |rows|
    valid_rows = rows.select do |row|
      session_id = row['Session ID'].to_i
      session_id.positive? && valid_session_ids.include?(session_id)
    end
    next if valid_rows.empty?

    data_point_count += valid_rows.size
    HrmDataPoint.upsert_all(
      valid_rows.map do |row|
        {
          hrm_session_id: row['Session ID'].to_i,
          beats_per_minute: row['Beats Per Minute'].to_i,
          reading_start_time: row['Reading Start Time'],
          reading_end_time: row['Reading End Time'],
          duration_in_secs: row['Duration in Secs'].to_i
        }
      end,
      unique_by: [ :hrm_session_id, :reading_start_time ]
    )
    puts "Imported #{data_point_count} data points"
  end
end

puts "Data import completed!"

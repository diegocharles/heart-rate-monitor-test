require 'open-uri'
require 'csv'
require 'zip'

# [TODO] - Move this complex logic to a Model (Service) with the help with a Rake Task if it's used more than once.

data_url = 'https://assets.benny.ai/code-test/heart-rate-monitor/data.zip'

tmp_dir = Rails.root.join('tmp')
FileUtils.mkdir_p(tmp_dir)
zip_path = tmp_dir.join('data.zip')

puts "Downloading data from #{data_url}..."
URI.open(data_url) do |remote_file|
  File.open(zip_path, 'wb') do |file|
    file.write(remote_file.read)
  end
end

extracted_path = tmp_dir.join('data')
FileUtils.mkdir_p(extracted_path)

puts "Extracting files..."
Zip::File.open(zip_path) do |zip_file|
  zip_file.each do |entry|
    entry.extract(File.join(extracted_path, entry.name)) { true }
  end
end

users_csv       = File.join(extracted_path, 'users.csv')
sessions_csv    = File.join(extracted_path, 'hrm_sessions.csv')
data_points_csv = File.join(extracted_path, 'hrm_data_points.csv')

# Disable indexes temporarily for faster imports
ActiveRecord::Base.connection.execute("PRAGMA synchronous = OFF")
ActiveRecord::Base.connection.execute("PRAGMA journal_mode = MEMORY")

# Disable indexes
ActiveRecord::Base.connection.execute("PRAGMA defer_foreign_keys = ON")
ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = OFF")

ActiveRecord::Base.transaction do
  puts "Importing users..."
  users_records = []
  CSV.foreach(users_csv, headers: true) do |row|
    users_records << {
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
    if users_records.size >= 1000
      User.insert_all(users_records)
      users_records = []
    end
  end
  User.insert_all(users_records) unless users_records.empty?

  puts "Importing HRM sessions..."
  sessions_records = []
  CSV.foreach(sessions_csv, headers: true) do |row|
    user_id = row['User ID'].to_i
    next if user_id.zero?

    sessions_records << {
      id: row['Session ID'].to_i,
      user_id: user_id,
      created_at: row['Created At'],
      duration_in_secs: row['Duration in Secs'].to_i
    }
    if sessions_records.size >= 1000
      HrmSession.insert_all(sessions_records)
      sessions_records = []
    end
  end
  HrmSession.insert_all(sessions_records) unless sessions_records.empty?

  puts "Importing HRM data points... Go grab a good cup of :coffee: and don't forget to drink 2l of water every day :droplet:"
  data_points_records = []
  CSV.foreach(data_points_csv, headers: true) do |row|
    hrm_session_id = row['Session ID'].to_i
    next if hrm_session_id.zero?

    data_points_records << {
      hrm_session_id: hrm_session_id,
      beats_per_minute: row['Beats Per Minute'].to_i,
      reading_start_time: row['Reading Start Time'],
      reading_end_time: row['Reading End Time'],
      duration_in_secs: row['Duration in Secs'].to_i
    }
    if data_points_records.size >= 1000
      HrmDataPoint.insert_all(data_points_records)
      data_points_records = []
    end
  end
  HrmDataPoint.insert_all(data_points_records) unless data_points_records.empty?
end

# Re-enable indexes and sync mode
ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON")
ActiveRecord::Base.connection.execute("PRAGMA defer_foreign_keys = OFF")
ActiveRecord::Base.connection.execute("PRAGMA synchronous = NORMAL")
ActiveRecord::Base.connection.execute("PRAGMA journal_mode = DELETE")

# Rebuild indexes
ActiveRecord::Base.connection.execute("REINDEX")

puts "Data import completed!"

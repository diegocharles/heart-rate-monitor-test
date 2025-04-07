class PopulateCachedStatistics < ActiveRecord::Migration[7.1]
  def up
    HrmSession.find_each { |session| HrmSession.reset_counters(session.id, :hrm_data_points) }
    User.find_each { |user| User.reset_counters(user.id, :hrm_sessions) }

    HrmSession.find_each do |session|
      next unless session.hrm_data_points.any?

      session.update_columns(
        min_bpm: session.hrm_data_points.minimum(:beats_per_minute),
        max_bpm: session.hrm_data_points.maximum(:beats_per_minute),
        avg_bpm: session.hrm_data_points.average(:beats_per_minute).round
      )
    end
  end

  def down
  end
end

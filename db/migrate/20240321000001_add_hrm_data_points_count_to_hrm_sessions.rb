class AddHrmDataPointsCountToHrmSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :hrm_sessions, :hrm_data_points_count, :integer, default: 0, null: false

    HrmSession.find_each do |session|
      HrmSession.reset_counters(session.id, :hrm_data_points)
    end
  end
end

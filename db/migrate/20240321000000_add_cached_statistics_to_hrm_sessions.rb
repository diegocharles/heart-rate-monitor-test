class AddCachedStatisticsToHrmSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :hrm_sessions, :min_bpm, :integer
    add_column :hrm_sessions, :max_bpm, :integer
    add_column :hrm_sessions, :avg_bpm, :integer

    # Add indexes for better query performance
    add_index :hrm_sessions, :min_bpm
    add_index :hrm_sessions, :max_bpm
    add_index :hrm_sessions, :avg_bpm
  end
end

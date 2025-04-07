class AddUniqueIndexToHrmDataPoints < ActiveRecord::Migration[7.1]
  def change
    add_index :hrm_data_points, [ :hrm_session_id, :reading_start_time ], unique: true, name: 'index_hrm_data_points_on_session_and_start_time'
  end
end

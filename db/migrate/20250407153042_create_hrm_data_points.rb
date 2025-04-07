class CreateHrmDataPoints < ActiveRecord::Migration[8.0]
  def change
    create_table :hrm_data_points do |t|
      t.references :hrm_session, null: false, foreign_key: true
      t.integer :beats_per_minute
      t.datetime :reading_start_time
      t.datetime :reading_end_time
      t.integer :duration_in_secs

      t.timestamps
    end
  end
end

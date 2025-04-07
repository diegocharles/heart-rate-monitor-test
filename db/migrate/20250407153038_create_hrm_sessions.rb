class CreateHrmSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :hrm_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :duration_in_secs

      t.timestamps
    end
  end
end

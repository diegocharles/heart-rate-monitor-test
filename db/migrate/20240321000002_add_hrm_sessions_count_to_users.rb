class AddHrmSessionsCountToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :hrm_sessions_count, :integer, default: 0, null: false

    User.find_each do |user|
      User.reset_counters(user.id, :hrm_sessions)
    end
  end
end

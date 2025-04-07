class User < ApplicationRecord
  has_many :hrm_sessions, dependent: :destroy
end

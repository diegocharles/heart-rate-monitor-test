class HrmSession < ApplicationRecord
  belongs_to :user
  has_many :hrm_data_points, dependent: :destroy
end

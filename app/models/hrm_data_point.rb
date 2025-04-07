class HrmDataPoint < ApplicationRecord
  belongs_to :hrm_session, counter_cache: true
end

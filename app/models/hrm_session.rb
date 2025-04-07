class HrmSession < ApplicationRecord
  belongs_to :user, counter_cache: true
  has_many :hrm_data_points, dependent: :destroy

  after_touch :update_cached_statistics

  def calculate_zone_percentages
    total_duration = duration_in_secs
    {
      1 => (hrm_data_points.where(beats_per_minute: user.hr_zone1_bpm_min..user.hr_zone1_bpm_max).sum(:duration_in_secs).to_f / total_duration * 100).round(1),
      2 => (hrm_data_points.where(beats_per_minute: user.hr_zone2_bpm_min..user.hr_zone2_bpm_max).sum(:duration_in_secs).to_f / total_duration * 100).round(1),
      3 => (hrm_data_points.where(beats_per_minute: user.hr_zone3_bpm_min..user.hr_zone3_bpm_max).sum(:duration_in_secs).to_f / total_duration * 100).round(1),
      4 => (hrm_data_points.where(beats_per_minute: user.hr_zone4_bpm_min..user.hr_zone4_bpm_max).sum(:duration_in_secs).to_f / total_duration * 100).round(1)
    }
  end

  private

  def update_cached_statistics
    return unless hrm_data_points.any?

    update_columns(
      min_bpm: hrm_data_points.minimum(:beats_per_minute),
      max_bpm: hrm_data_points.maximum(:beats_per_minute),
      avg_bpm: hrm_data_points.average(:beats_per_minute).round
    )
  end
end

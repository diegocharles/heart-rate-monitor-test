class DashboardController < ApplicationController
  def index
    @sessions = HrmSession.includes(:user, :hrm_data_points)
                         .order(created_at: :desc)
                         .limit(10)
    @overall_stats = calculate_overall_statistics
    @zone_percentages = calculate_zone_percentages
  end

  private

  def calculate_overall_statistics
    {
      min_heart_rate: HrmDataPoint.minimum(:beats_per_minute),
      max_heart_rate: HrmDataPoint.maximum(:beats_per_minute),
      avg_heart_rate: HrmDataPoint.average(:beats_per_minute).to_i
    }
  end

  def calculate_zone_percentages
    total_duration = HrmDataPoint.sum(:duration_in_secs).to_f

    zones = User.all.map do |user|
      zone_durations = calculate_zone_durations_for_user(user)
      total_user_duration = zone_durations.values.sum.to_f

      percentages = zone_durations.transform_values do |duration|
        ((duration / total_user_duration) * 100).round(2)
      end

      { user: user, percentages: percentages }
    end

    zones
  end

  def calculate_zone_durations_for_user(user)
    {
      zone1: HrmDataPoint.joins(:hrm_session)
                        .where(hrm_sessions: { user_id: user.id })
                        .where("beats_per_minute BETWEEN ? AND ?", user.hr_zone1_bpm_min, user.hr_zone1_bpm_max)
                        .sum(:duration_in_secs),
      zone2: HrmDataPoint.joins(:hrm_session)
                        .where(hrm_sessions: { user_id: user.id })
                        .where("beats_per_minute BETWEEN ? AND ?", user.hr_zone2_bpm_min, user.hr_zone2_bpm_max)
                        .sum(:duration_in_secs),
      zone3: HrmDataPoint.joins(:hrm_session)
                        .where(hrm_sessions: { user_id: user.id })
                        .where("beats_per_minute BETWEEN ? AND ?", user.hr_zone3_bpm_min, user.hr_zone3_bpm_max)
                        .sum(:duration_in_secs),
      zone4: HrmDataPoint.joins(:hrm_session)
                        .where(hrm_sessions: { user_id: user.id })
                        .where("beats_per_minute BETWEEN ? AND ?", user.hr_zone4_bpm_min, user.hr_zone4_bpm_max)
                        .sum(:duration_in_secs)
    }
  end
end

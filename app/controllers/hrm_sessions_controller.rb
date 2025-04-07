class HrmSessionsController < ApplicationController
  include Pagy::Backend

  # TODO - Implement Infinite scroll with Hotwire
  def index
    @pagy, @hrm_sessions = pagy(
      HrmSession.includes(:user).order(created_at: :desc),
      items: 50
    )
  end

  def show
    @hrm_session = HrmSession.includes(:user, :hrm_data_points).find(params[:id])
    @zone_percentages = @hrm_session.calculate_zone_percentages
  end
end

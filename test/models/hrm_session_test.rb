require "test_helper"

class HrmSessionTest < ActiveSupport::TestCase
  def setup
    @user = users(:test_user)
    @session = hrm_sessions(:short_session)
  end

  test "should belong to user" do
    assert_respond_to @session, :user
    assert_not_nil @session.user
  end

  test "should have many data points" do
    assert_respond_to @session, :hrm_data_points
    assert_not_nil @session.hrm_data_points
  end

  test "should require user" do
    @session.user = nil
    assert_not @session.valid?
    assert_includes @session.errors[:user], "must exist"
  end

  test "should calculate zone percentages correctly" do
    # Create a session with data points in different zones
    session = HrmSession.create!(
      user: @user,
      duration_in_secs: 240 # Adjusted to match the 4 zones
    )

    start_time = Time.current
    # Add data points in different zones
    session.hrm_data_points.create!(
      beats_per_minute: 100, # Zone 1
      duration_in_secs: 60,
      reading_start_time: start_time,
      reading_end_time: start_time + 60.seconds
    )
    session.hrm_data_points.create!(
      beats_per_minute: 130, # Zone 2
      duration_in_secs: 60,
      reading_start_time: start_time + 60.seconds,
      reading_end_time: start_time + 120.seconds
    )
    session.hrm_data_points.create!(
      beats_per_minute: 150, # Zone 3
      duration_in_secs: 60,
      reading_start_time: start_time + 120.seconds,
      reading_end_time: start_time + 180.seconds
    )
    session.hrm_data_points.create!(
      beats_per_minute: 170, # Zone 4
      duration_in_secs: 60,
      reading_start_time: start_time + 180.seconds,
      reading_end_time: start_time + 240.seconds
    )

    percentages = session.calculate_zone_percentages

    assert_equal 4, percentages.size
    assert_in_delta 25.0, percentages[1], 0.1 # Zone 1
    assert_in_delta 25.0, percentages[2], 0.1 # Zone 2
    assert_in_delta 25.0, percentages[3], 0.1 # Zone 3
    assert_in_delta 25.0, percentages[4], 0.1 # Zone 4
    assert_in_delta 100.0, percentages.values.sum, 0.1
  end

  test "should update cached statistics when data points change" do
    session = HrmSession.create!(
      user: @user,
      duration_in_secs: 300
    )

    start_time = Time.current
    # Add initial data point
    session.hrm_data_points.create!(
      beats_per_minute: 100,
      duration_in_secs: 60,
      reading_start_time: start_time,
      reading_end_time: start_time + 60.seconds
    )

    session.touch
    session.reload

    assert_equal 100, session.min_bpm
    assert_equal 100, session.max_bpm
    assert_equal 100, session.avg_bpm

    # Add another data point
    session.hrm_data_points.create!(
      beats_per_minute: 150,
      duration_in_secs: 60,
      reading_start_time: start_time + 60.seconds,
      reading_end_time: start_time + 120.seconds
    )

    session.touch
    session.reload

    assert_equal 100, session.min_bpm
    assert_equal 150, session.max_bpm
    assert_equal 125, session.avg_bpm
  end

  test "should destroy associated data points" do
    assert_difference "HrmDataPoint.count", -@session.hrm_data_points.count do
      @session.destroy
    end
  end

  test "should update counter cache on user" do
    assert_difference "@user.hrm_sessions_count", 1 do
      HrmSession.create!(
        user: @user,
        duration_in_secs: 300
      )
    end
  end
end

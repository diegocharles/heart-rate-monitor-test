require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:test_user)
  end

  test "should have many hrm sessions" do
    assert_respond_to @user, :hrm_sessions
    assert_not_nil @user.hrm_sessions
  end
end

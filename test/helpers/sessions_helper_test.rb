# A test for persistent sessions listing 9.31
require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

  def setup
    @user = users(:michael) #Define a user variable using the fixtures.
    remember(@user) #Call the remember method to remember the given user.
  end

  test "current_user returns right user when session is nil" do
    assert_equal @user, current_user #Verify that current_user is equal to the given user.
    assert is_logged_in? #is user logged in?
  end

  test "current_user returns nil when remember digest is wrong" do #thereby testing the authenticated? expression "if user && user.authenticated?(cookies[:remember_token])"
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
end

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

 #protect the index page from unauthorized access
  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

#getting sign up page test
  test "should get new" do
    get signup_path
    assert_response :success
  end
#issue redirects when accessing something protected pages; cannot access those if not logged in (account, profile, etc.)
  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

#checks to see if the admin attribute in the database can be edited (it should not be allowed to be!)
  test "should not allow the admin attribute to be edited via the web" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: {
        user: { password:              'password', #this is updating the info not checking for comparison
                password_confirmation: 'password',
                admin: true} } #patch request for admin value to be true for this user
    assert_not @other_user.reload.admin? #reload the admin value so now it becomes true
  end

#issue redirects if user is not the correct one(such as you viewing other users pages; should not be able to edit those pages)
  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end

#Action-level tests for admin access control
#issue delete request to destroy action to delete users; check for two cases
#We need to check two cases: first, users who aren’t logged in should be redirected to the login page;
#second, users who are logged in but who aren’t admins should be redirected to the Home page
  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do #no change to amount of users
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do #no change to amount of users
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end
end
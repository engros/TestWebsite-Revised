require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "login with invalid information" do
    get login_path #visit login path
    assert_template 'sessions/new' #Visit login page
    post login_path, params: { session: { email: "", password: "" } }#invalid login information
    assert_template 'sessions/new' #When info entered is wrong rerender the login page
    assert_not flash.empty? #verify that login error message appears during failed login
    get root_path #visit home page
    assert flash.empty? #verify that after visiting to home page after login failure the error message disappears
  end

  test "login with valid information" do
    get login_path
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }
    assert is_logged_in? #check that user is in session
    assert_redirected_to @user #check the right redirect target
    follow_redirect! #actually visit the target page
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0 #verifies that the login link disappears by verifying that there are zero login path links on the page
    assert_select "a[href=?]", logout_path #verify that once logged in a logout link appears
    assert_select "a[href=?]", user_path(@user) #verify that a profile link appears once logged in
    delete logout_path
    assert_not is_logged_in? #check that user is not in session
    assert_redirected_to root_url #check redirect go back to home page
    # Simulate a user clicking logout in a second window.
    delete logout_path
    follow_redirect! #actually go to that home page
    assert_select "a[href=?]", login_path     #verify that login link appears after logout
    assert_select "a[href=?]", logout_path,      count: 0 #verify that logout link has disappeared
    assert_select "a[href=?]", user_path(@user), count: 0 #verify that profile link disappeared
  end

  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    assert_not_nil cookies['remember_token']
  end

  test "login without remembering" do
    log_in_as(@user, remember_me: '0')
    assert_nil cookies['remember_token']
  end

end

=begin
This is what each line of code means for test "login with invalid information":

Visit the login path.
Verify that the new sessions form renders properly.
Post to the sessions path with an invalid params hash.
Verify that the new sessions form gets re-rendered
and that a flash message appears.
Visit another page (such as the Home page).
Verify that the flash message doesn’t appear on the new page.

=end

=begin

This is what each line of code means for test "login with valid information followed by logout":

Visit the login path.
Post valid information to the sessions path.
Check to see if the user is in session
Check the right redirect target
Actually visit the target page
Show the user that just logged in, account page
Verify that the login link disappears, since you just logged in.
Verify that once logged in a logout link appears
Verify that a profile link appears.
logout
check if user is still logged in
(subtlety bug check) simulate second window logout
go back to home page
verify login link appears in home page after logout
verify that logout link disappeard since already logged out
verify that profile link disappears since already logged out
=end

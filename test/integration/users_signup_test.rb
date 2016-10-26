require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear #because deliveries array is global, we have to reset it in the setup method to prevent our code from breaking any other tests deliver email
  end

  test "invalid signup information" do
    get signup_path #get the signup path
    assert_no_difference 'User.count' do #check that users didn't increase since invalid signup
      post users_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    assert_template 'users/new' #check for signup page
    assert_select 'div#error_explanation' #are there error messages?
    assert_select 'div.field_with_errors'
  end

  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do #check that users increased! since it is valid signup
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size #this code verifies that exactly 1 message was delivered
    user = assigns(:user) #assigns method lets us access instance variables (user) in the corresponding actions such as create method that defines user variable
    assert_not user.activated? #check if user is not activated yet
    # Try to log in before activation.
    log_in_as(user)
    assert_not is_logged_in? #check that user is not logged in before activation
    # Invalid activation token
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # Valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # Valid activation token
    get edit_account_activation_path(user.activation_token, email: user.email) #get activation token using find_by(email)
    assert user.reload.activated? #once token is found, reload since activation token is taken from database;
    follow_redirect!
    assert_template 'users/show' #go to user profile
    assert is_logged_in? #check if that valid user is now logged in
  end

end

=begin
Using assert_select (assert_no_difference) to test HTML elements of the relevant pages, taking care to check only elements unlikely to change in the future.
By wrapping the post in the assert_no_difference method with the string argument ’User.count’, we arrange for a comparison between User.count before and after the contents inside the assert_no_difference block.

assert is_logged_in is created in the test_helper module to check if session has a user in it or not, if there is then user is logged in upon sign up or not
=end

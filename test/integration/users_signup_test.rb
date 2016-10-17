require 'test_helper'

require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      assert_select 'form[action="/signup"]' # test presence of /signup so that url for unsubmitted and submitted sign up are the same signup_path
      post users_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    assert_template 'users/new'
    assert_select 'div#<CSS id for error explanation>'
    assert_select 'div.<CSS class for field with error>'
  end

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    follow_redirect!
    assert_template 'users/show'
  end
end

=begin
Using assert_select (assert_no_difference) to test HTML elements of the relevant pages, taking care to check only elements unlikely to change in the future.
By wrapping the post in the assert_no_difference method with the string argument ’User.count’, we arrange for a comparison between User.count before and after the contents inside the assert_no_difference block.
=end

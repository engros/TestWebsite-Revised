#a test of the users index, including pagination

require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
  end

 #An integration test for delete links and destroying users
  test "index as admin including pagination and delete links" do
    log_in_as(@admin) #log in as admin
    get users_path #check that you can go to this user's profile page (user exists!)
    assert_template 'users/index' #check that you can go to index page of all users
    assert_select 'div.pagination' #check that the index page has pagination (looking at div)
    first_page_of_users = User.paginate(page: 1) #check than page 1 of pagination exists (30 chunks of users)
    first_page_of_users.each do |user| #for each user
      assert_select 'a[href=?]', user_path(user), text: user.name #check that their profile pages are accessible and their names displayed
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete' #only for admins; check that there is a delete option for each user
      end
    end
    assert_difference 'User.count', -1 do #successful deletion of user reduces amount of users by 1
      delete user_path(@non_admin) #delete the profile page of this non-admin user
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin) #log in as a non-admin user
    get users_path #check that you can go to this user's profile page (user exists!)
    assert_select 'a', text: 'delete', count: 0 #check that this non-admin user has no delete link that is accessible
  end


end
class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy] #arrange logged_in_user method to be called before any given actions
  before_action :correct_user,   only: [:edit, :update] #arrange correct_user method to be called before anything below
  before_action :admin_user,     only: :destroy #first check to see if this user is an admin before any deletions, only admins can do user deletions

  def index
    @users = User.paginate(page: params[:page]) #pageinate users in chunks of 30 users per page
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user #will login new user upon sign up
      flash[:success] =  "Welcome to Mark's Sample App"
      redirect_to @user #if new user is successfully save, go to profile page
    else
      render 'new' #if info entered is invalid re-render the new page
    end
  end

  def edit
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated" # Handle a successful update.
      redirect_to @user #redirect to profile page
    else
      render 'edit' #if info entered is invalid, re-render the edit page
    end
  end

  def destroy #admins can delete users
    User.find(params[:id]).destroy #delete the user using id
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private

    def user_params #strong parameters adds security by only allowing changed to these parameters and nothing else like admin or password_digest in the database
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation) #include :admin to use users_controller_test to test for invalidity of cyber attack patch request for admin value change
    end

    # Before filters

    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in? #if not logged in then
        store_location #call store_location method in session_helper.rb; store location of requested page
        flash[:danger] = "Please log in." #warn the user to log in first
        redirect_to login_url
      end
    end

    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    # Confirms an admin user.
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end

=begin
-used params to retrieve the user id. When we make the appropriate request to the Users controller,
params[:id] will be the user id 1, so the effect is the same as the find method User.find(1)
-before_action calls methods before anything below it
-logged_in_user implements a forwarding behavior for non-logged/unauthorized users (cannot access certain options in website)
-correct_user redirects users trying to edit another user's profile
-correct_user is called before anything below it and defines @user variable, therefore edit and update actions doesn't need @user assignnment
=end


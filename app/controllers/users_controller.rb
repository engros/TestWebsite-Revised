class UsersController < ApplicationController

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
      render 'new'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end
end

=begin
used params to retrieve the user id. When we make the appropriate request to the Users controller,
params[:id] will be the user id 1, so the effect is the same as the find method User.find(1)
=end

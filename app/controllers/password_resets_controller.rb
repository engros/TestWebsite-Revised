class PasswordResetsController < ApplicationController

  before_action :get_user,   only: [:edit, :update] #arranges to call get_user first before running edit or update action
  before_action :valid_user, only: [:edit, :update] #arranges to call valid_user method first before running edit or update action
  before_action :check_expiration, only: [:edit, :update]    # Case (1)

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  #display an edit form
  def edit
  end

  def update
    if params[:user][:password].empty?                  # Case (3)
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    elsif @user.update_attributes(user_params)          # Case (4)
      log_in @user
      @user.update_attribute(:reset_digest, nil) #exercise 12.3.3.3; If a user reset their password from a public machine, anyone could press the back button and change the password (and get logged in to the site). This clears the reset digest on successful password update
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit'                                     # Case (2)
    end
  end


  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def get_user
        @user = User.find_by(email: params[:email])
      end

    # Confirms a valid user. Redirect to home page if user is neither activated nor authenticated
    def valid_user
      unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # Checks expiration of reset token.
    def check_expiration
      if @user.password_reset_expired? #uses instance method defined in user.rb password_reset_expired to check if expired (true) or not (false)
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end


end
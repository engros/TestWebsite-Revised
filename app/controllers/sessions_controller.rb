class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase) #find email using Active Record find_by method using form_for submitted values of params hash
    if user && user.authenticate(params[:session][:password])#but only log in if a user with the given email both exists in the database and has the given password, exactly as required.
      if user.activated? #instance method checks to see if this user is activated
        log_in user #if activated then auto login
        params[:session][:remember_me] == '1' ? remember(user) : forget(user) #if remember checkbox is checked, remember the user with cookie
        redirect_back_or user #go to profile page
      else #if not activated
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url #redirect to home page
      end
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in? #instance method checks only logged out if logged in (two window used subtle bug check)
    redirect_to root_url
  end
end

# authenticate method verifies that the submitted virtual password matches the password digest
# using flash.now instead of just flash will display flash messages on rendered pages but its contents
# disappear as soon as there is an additional request

# session_helper module will be used to package methods that can be reused for logging in
# params[:session][:remember me] == '1' uses ternary operator to decide if the remember me box is check to 1 or not
# if params[][] is equal to 1 then remember user, if not then forget user
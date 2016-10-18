class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase) #find email using Active Record find_by method using form_for submitted values of params hash
    if user && user.authenticate(params[:session][:password])#but only log in if a user with the given email both exists in the database and has the given password, exactly as required.
      log_in user # Log the user in by using sessionhelper's log_in method, passing user params
      redirect_to user # rails converts this to user_url(user), redirect to the user's show page
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end

# using flash.now instead of just flash will display flash messages on rendered pages but its contents
# disappear as soon as there is an additional request

#session_helper module will be used to package methods that can be reused for logging in
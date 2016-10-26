#Activates the user's account after clicking Activate on the sent email
class AccountActivationsController < ApplicationController

  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.update_attribute(:activated,    true) #change activate attribute in database to true
      user.update_attribute(:activated_at, Time.zone.now) #update time activated
      user.activate
      log_in user #login automatically after activation
      flash[:success] = "Account activated!"
      redirect_to user #redirect to profile page
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url #redirect to home page if activation link is invalid
    end
  end
end

=begin
-if user &&... line are boolean values that first checks to see if activation token is same as activation digest then checks to see if the user is activated or not
-!user.activated? disallows any already activated users from activating again
=end
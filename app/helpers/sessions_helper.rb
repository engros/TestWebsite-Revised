module SessionsHelper

  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id #saves the user id in session method
  end
  # Returns the current logged-in user (if any).
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end
  # Logs out the current user.
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end

=begin

-Sessions helper module was generated automatically when generating the Sessions controller,
by including the module into the base class of all controllers (the Application controller),
we arrange to make them available in all our controllers as well
-the log_in method can be used as a technique in a couple of different places (code reusability)
-note that session method is a temporary cookie and is secure, but is destroyed once browser closes
-the permanent cookie is made with cookie method, but is vulnerable to cyber attacks
-find method raises an exception when id is invalid, so find_by is used instead since it only returns nil if id is invalid
-by storing the result of find_by to instance variable @current_user, this prevents hitting database multiple times
 if current_user appears many times on the same page. A very similar method to this is:

      if @current_user.nil?
        @current_user = User.find_by(id: session[:user_id])
      else
        @current_user
      end

-
=end


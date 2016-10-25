module SessionsHelper

  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id #saves the user id in session method
  end

  # Remembers a user in a persistent session.
  def remember(user)
    user.remember #will call remember method from user.rb, generating a remember token and saving its digest to the database
    cookies.permanent.signed[:user_id] = user.id #signed is Rails method that securely encrypts cookie before placing it on the browser; creates permanent cookies for user id
    cookies.permanent[:remember_token] = user.remember_token #permanent is Rails method setting cookies to expire 20 years; create permanent cookies for remember token
  end

  # Returns true if the given user is the current user.
  def current_user?(user)
    user == current_user
  end

  # Returns the user corresponding to the remember token cookie.
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)#find user info in database (Active Record) by id and compare with virtual info, if matched save as current session user
    elsif (user_id = cookies.signed[:user_id])
      #raise       # Use this to test sessions_helper_test.rb
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  # Forgets a persistent session. So user is not forever logged in
  def forget(user)
    user.forget #calls user.rb forget method
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Logs out the current user.
  def log_out
    forget(current_user) #calls the forget method to forget user (session) when logging out
    session.delete(:user_id)
    @current_user = nil
  end

  # Redirects to stored location (or to the default).
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default) #go to requested page if it exists, otherwise go to the dafault page (eg. profile instead of edit)
    session.delete(:forwarding_url) #delete the stored requested url
  end

  # Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.original_url if request.get? #uses requested object via request.original_url to get the URL of the requested page
  end

end

=begin

-Sessions helper module was generated automatically when generating the Sessions controller,
by including the module into the base class of all controllers (the Application controller),
we arrange to make them available in all our controllers as well
-the log_in method can be used as a technique in a couple of different places (code reusability)
-note that session method is a temporary cookie and is secure, but is destroyed once browser closes
-the permanent cookie is made with cookie method, but is vulnerable to session hijacking
-find method raises an exception when id is invalid, so find_by is used instead since it only returns nil if id is invalid
-by storing the result of find_by to instance variable @current_user, this prevents hitting database multiple times
 if current_user appears many times on the same page. A very similar method to this is:

      if @current_user.nil?
        @current_user = User.find_by(id: session[:user_id])
      else
        @current_user
      end

-the current_user method ensures that newly logged in users are correctly remembered, so while logged in then closing the browser and coming back
 you are still logged in when restarting/revisiting application

-redirect_back_or and store_location used to forward users to their intended destination (eg. edit instead of users/1). Store the location
 somewhere and then redirect to that location instead of the default.
-store_location method puts requested URL in session variable under the key :forwarding_url, but only for a GET request. Preventing storing the forwarding
 URL if a user submits a form when not logged in. Resulting redirect would issue a GET request to URL expecting POST, PATCH, DELETE, causing error.
 The if request.get? prevents this from happening.
=end


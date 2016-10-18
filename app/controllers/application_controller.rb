class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
end

=begin

Sessions helper module was generated automatically when generating the Sessions controller,
by including the module into the base class of all controllers (the Application controller),
we arrange to make them available in all our controllers as well

=end
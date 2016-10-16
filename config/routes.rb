Rails.application.routes.draw do
  get 'users/new'

  root 'static_pages#home'
  get  '/help',    to: 'static_pages#help'
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'
  get  '/signup',  to: 'users#new'
end

=begin
# get pattern routes a GET request for the URL /help to the help action in the Static Pages controller.
As with the rule for the root route, this creates two named routes, help_path and help_url
=end

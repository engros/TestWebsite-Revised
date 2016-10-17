Rails.application.routes.draw do
  root 'static_pages#home'
  get  '/help',    to: 'static_pages#help'
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'
  get  '/signup',  to: 'users#new'
  post '/signup',  to: 'users#create'
  resources :users
end

=begin
get pattern routes a GET request for the URL /help to the help action in the Static Pages controller.
As with the rule for the root route, this creates two named routes, help_path and help_url
=end

=begin resources :users, it endows our sample application with all the actions needed for a
RESTful Users resource,6 along with a large number of named routes for generating user URLs.
Use rake routes to look at current RESTful routes
=end

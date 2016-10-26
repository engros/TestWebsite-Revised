Rails.application.routes.draw do
  get 'password_resets/new'

  get 'password_resets/edit'

  root   'static_pages#home'
  get    '/help',    to: 'static_pages#help'
  get    '/about',   to: 'static_pages#about'
  get    '/contact', to: 'static_pages#contact'
  get    '/signup',  to: 'users#new'
  post   '/signup',  to: 'users#create'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  resources :users #named routes for patch/edit, destroy/delete
  resources :account_activations, only: [:edit] #named route for the edit action to activate account using email of account_activations_controller
  resources :password_resets,     only: [:new, :create, :edit, :update] #name routes for password resetting but only for new, create, edit, update actions of password_resets_controller
end

=begin
get pattern routes a GET request for the URL /help to the help action in the Static Pages controller.
As with the rule for the root route, this creates two named routes, help_path and help_url
=end

=begin resources :users, it endows our sample application with all the actions needed for a
RESTful Users resource,6 along with a large number of named routes for generating user URLs.
Use rake routes to look at current RESTful routes
=end

=begin
When login_path is used as passed value inside a form_for, Rails infers the action as a POST to create action
=end

=begin
named routes create _path(relative) and _url(absolute) (Exercise 11.1.1.2 )
  - _url is used mostly for emails sending links from outside to the app on the server (providing links for external use)
  - Think email links, RSS, and things like the copy and paste URL field under a YouTube video's "Share" section.
=end

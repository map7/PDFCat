ActionController::Routing::Routes.draw do |map|
  map.resources :firms

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.resources :users

  map.resource :session

  map.resources :pdfs,
    :collection => {
                    :attachment_new => :get,
                    :email => :get,
                    :assign_file => :post
                   },
    :member => {:assign => :get}
  map.resources :clients
  map.resources :categories
  map.resources :missing

  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'

  map.resources :new_pdfs
  map.missing '/missing', :controller => 'missing'
  
  # RESTful ACL
  map.error '/error', :controller => 'sessions', :action => 'error'
  map.denied '/denied', :controller => 'sessions', :action => 'denied'

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up ''
  # -- just remember to delete public/index.html.
  map.root :controller => "pdfs"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

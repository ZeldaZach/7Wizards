ActionController::Routing::Routes.draw do |map|

  map.root :controller => 'visitor'
  
  map.logout 'logout', :controller => 'application', :action => 'logout'
  map.login 'login', :controller => 'visitor', :action => 'index'
  map.restore 'restore', :controller => 'visitor', :action => 'restore'
  map.public_profile 'p/:name', :controller => 'visitor', :action => 'profile'
  map.reference_register 'r/:name', :controller => 'visitor', :action => 'reference_register'

  map.admin_news 'admin/news/:action/:id', :controller => 'admin/news', :action => 'index', :id => nil
  map.admin_reports 'admin/reports/:action/:id', :controller => 'admin/reports', :action => 'index', :id => nil
  map.admin_support 'admin/support/:action/:id', :controller => 'admin/support', :action => 'index', :id => nil
  map.admin_users 'admin/users/:action/:id', :controller => 'admin/users', :action => 'index', :id => nil
  map.admin_chat 'admin/chat/:action/:id', :controller => 'admin/chat', :action => 'index', :id => nil
  map.admin 'admin/:action/:id', :controller => 'admin', :action => 'index', :id => nil

  map.visitor 'visitor/:action/:id', :controller => 'visitor', :action => 'index', :id => nil
  map.wizards 'wizards/:action/:id', :controller => 'wizards', :action => 'index', :id => nil
  map.home    'home/:action/:id', :controller => 'wizards/home', :action => 'index', :id => nil
  map.profile 'profile/:action/:id', :controller => 'wizards/profile', :action => 'index', :id => nil
  map.shop    'shop/:action/:id', :controller => 'wizards/shop', :action => 'index', :id => nil
  map.chat    'chat/:action/:id', :controller => 'wizards/chat', :action => 'index', :id => nil
  map.mail    'mail/:action/:id', :controller => 'wizards/mail', :action => 'index', :id => nil
  map.fight   'fight/:action/:id', :controller => 'wizards/fight', :action => 'index', :id => nil
  map.clan    'clan/:action/:id', :controller => 'wizards/clan', :action => 'index', :id => nil
  map.respect 'respect/:action/:id', :controller => 'wizards/respect', :action => 'index', :id => nil
  map.relation 'relation/:action/:id', :controller => 'wizards/relation', :action => 'index', :id => nil
  map.pet      'pet/:action/:id', :controller => 'wizards/pet', :action => 'index', :id => nil
  map.buygold  'buygold/:action/:id', :controller => 'wizards/buygold', :action => 'index', :id => nil
  map.account  'account/:action/:id', :controller => 'wizards/account', :action => 'index', :id => nil
  map.dragon   'dragon/:action/:id', :controller => 'wizards/dragon', :action => 'index', :id => nil
  map.games    'games/:action/:id', :controller => 'wizards/games', :action => 'index', :id => nil
  map.adyen    'adyen/:action/:id', :controller => 'adyen', :action => 'index', :id => nil
  map.bigpoint 'bigpoint/:action/:id', :controller => 'bigpoint', :action => 'index', :id => nil
  map.xmlrpc   'xmlrpc', :controller => 'bigpoint', :action => 'xmlrpc'

  map.connect ':controller/:action'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
end

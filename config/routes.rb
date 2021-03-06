Rrw::Application.routes.draw do
  get "world/index"
  post "world/travel"
  post "world/attack"
  post "world/buy"
  post "world/sell"
  post "world/use"
  post "world/equip"
  post "world/unequip"
  get "world/chat"
  post "world/say"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'world#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  # resources :player
  get "player/index"
  get "player" => "player#index"
  post "player/reset"
  get "player/death"
  get "player/new"
  post "player/create"

  get "scores/index"
  get "scores" => "scores#index"

  get "sessions/index"
  get "sessions" => "sessions#index"
  get "/auth/google_login/callback" => "sessions#create"
  get "/signout" => "sessions#destroy", :as => :signout

  post "sessions/test"
  get "sessions/test"

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

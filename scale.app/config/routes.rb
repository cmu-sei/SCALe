# -*- coding: utf-8 -*-
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved. See COPYRIGHT file for details.

Scale::Application.routes.draw do

  get '/projects/new', to: 'projects#new'
  get '/projects/script', to: 'projects#script'
  get '/projects/:project_id', to: 'diagnostics#index'
  get '/projects/:project_id/unfused', to: 'diagnostics#unfused'
  get '/projects/:project_id/export', to: 'diagnostics#export'
  get '/projects/:project_id/exportdb', to: 'diagnostics#exportDB'
  get '/projects/:project_id/add', to: 'displays#new'
  get '/projects/:project_id/database', to: 'projects#database'
  post '/projects/:project_id/database', to: 'projects#database'
  post '/projects/:project_id/update_project', to: 'projects#update_project'
  post '/projects/:project_id/database/delete', to:'projects#nukeDatabase'
  post '/projects/:project_id/database/download', to:'projects#downloadDatabase'
  post '/projects/:project_id/database/fromdatabase', to: 'projects#fromDatabase'
  # get '/database/new', to: 'projects#database'
  # get '/database', to:'projects#database'
  # post '/database', to:'projects#database'
  # post '/database/new', to:'projects#database'
  # post '/database/delete', to:'projects#nukeDatabase'
  # post '/database/download', to:'projects#downloadDatabase'
  # post '/database/fromdatabase', to: 'projects#fromDatabase'
  get '/database/manual', to:'projects#manual'
  post '/diagnostics/fusedUpdate', to: 'diagnostics#fusedUpdate'

  resources :diagnostics
  resources :displays
  resources :projects

  root to: "projects#index"

  match '/diagnostics/update', to: 'diagnostics#massUpdate'
  post '/projects/:project_id/upload/gnu', to: 'projects#upload_gnu_pages'
  post '/projects/:project_id/upload/scale', to: 'projects#upload_scale_db'

  # match "*rest", to: redirect('/notfound.html')


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end

# -*- coding: utf-8 -*-

# <legal>
# SCALe version r.6.2.2.2.A
# 
# Copyright 2020 Carnegie Mellon University.
# 
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING
# INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON
# UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR
# IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF
# FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS
# OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT
# MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT,
# TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# 
# Released under a MIT (SEI)-style license, please see COPYRIGHT file or
# contact permission@sei.cmu.edu for full terms.
# 
# [DISTRIBUTION STATEMENT A] This material has been approved for public
# release and unlimited distribution.  Please see Copyright notice for
# non-US Government use and distribution.
# 
# DM19-1274
# </legal>

Scale::Application.routes.draw do

  get '/projects/new', to: 'projects#new'
  get '/projects/script', to: 'projects#script'
  get '/projects/:project_id', to: 'alert_conditions#index'
  post '/projects/:project_id', to: 'alert_conditions#index'
  get '/projects/:project_id/fused', to: 'alert_conditions#fused'
  get '/projects/:project_id/unfused', to: 'alert_conditions#unfused'
  get '/projects/:project_id/export', to: 'alert_conditions#export'
  get '/projects/:project_id/exportdb', to: 'alert_conditions#exportDB'
  get '/projects/:project_id/upload_project', to: 'alert_conditions#uploadProject'
  get '/projects/:project_id/add', to: 'displays#new'
  get '/displays/:project_id', to: 'displays#show'
  get '/displays/:project_id/message', to: 'displays#messages'
  get '/projects/:project_id/database', to: 'projects#database'
  post '/projects/:project_id/database', to: 'projects#database'
  get '/projects/:project_id/scaife', to: 'projects#scaife'
  post '/projects/:project_id/scaife', to: 'projects#scaife'
  post '/projects/:project_id/update_project', to: 'projects#update_project'
  post '/projects/:project_id/database/delete', to:'projects#nukeDatabase'
  post '/projects/:project_id/database/download', to:'projects#downloadDatabase'
  post '/projects/:project_id/database/fromdatabase', to: 'projects#fromDatabase'
  get '/projects/:project_id/showTable', to: 'alert_conditions#showTable'

  ### language/taxonomy/tool SCAIFE integrations

  # entry points
  get '/scaife_integration', to: 'projects#scaifeIntegration'
  get '/language_select', to: 'projects#langSelect'
  get '/language_upload', to: 'projects#langUpload'
  get '/language_map', to: 'projects#langMap'
  get '/taxonomy_select', to: 'projects#taxoSelect'
  get '/taxonomy_upload', to: 'projects#taxoUpload'
  get '/taxonomy_map', to: 'projects#taxoMap'
  get '/tool_upload', to: 'projects#toolUpload'
  get '/tool_map', to: 'projects#toolMap'
  # submissions
  post '/language_select_submit', to: 'projects#langSelectSubmit'
  post '/language_upload_submit', to: 'projects#langUploadSubmit'
  post '/language_map_submit', to: 'projects#langMapSubmit'
  post '/taxonomy_select_submit', to: 'projects#taxoSelectSubmit'
  post '/taxonomy_upload_submit', to: 'projects#taxoUploadSubmit'
  post '/taxonomy_map_submit', to: 'projects#taxoMapSubmit'
  post '/tool_select_submit', to: 'projects#toolSelectSubmit'
  post '/tool_upload_submit', to: 'projects#toolUploadSubmit'
  post '/tool_map_submit', to: 'projects#toolMapSubmit'

  # get '/database/new', to: 'projects#database'
  # get '/database', to:'projects#database'
  # post '/database', to:'projects#database'
  # post '/database/new', to:'projects#database'
  # post '/database/delete', to:'projects#nukeDatabase'
  # post '/database/download', to:'projects#downloadDatabase'
  # post '/database/fromdatabase', to: 'projects#fromDatabase'
  get '/database/manual', to:'projects#manual'
  post '/alertConditions/update-alerts', to: 'alert_conditions#updateAlertConditions'
  post '/alertConditions/log-supplemental', to: 'alert_conditions#LogSupplementalDetermination'
  post '/alertConditions/clearfilters', to: 'alert_conditions#clearFilters'
  post '/alertConditions/:project_id/classifier/run', to: 'alert_conditions#runClassifier'
  get '/scaife-registration/login', to: 'scaife_registration#getLoginModal'
  post '/scaife-registration/logout', to: 'scaife_registration#submitLogout'
  get '/scaife-registration/register', to: 'scaife_registration#getRegisterModal'
  post '/scaife-registration/register-submit', to: 'scaife_registration#submitRegister'
  post '/scaife-registration/login-submit', to: 'scaife_registration#submitLogin'

  get '/priorities/:priority_id/projects/:project_id/show', to: 'priority_schemes#show'
  post '/priorities/:project_id/save', to: 'priority_schemes#createPriority' #expects json contentType
  post '/priorities/:project_id/edit', to: 'priority_schemes#editPriority' #expects json contentType
  post '/priorities/:project_id/run', to: 'priority_schemes#runPriority'
  post '/priorities/delete', to: 'priority_schemes#deletePriority'

  post '/modals/userUpload', to: 'modals#uploadUserFields', defaults: { format: :json }
  get '/modals/mass-update', to: 'modals#massUpdate'

  get '/modals/open', to: 'classifier_schemes#getModals'
  post '/modals/classifier/create', to: 'classifier_schemes#createClassifier' #expects contentType: 'application/json'
  post '/modals/classifier/edit', to: 'classifier_schemes#editClassifier' #expects contentType: 'application/json'
  get '/modals/classifier/view', to: 'classifier_schemes#viewClassifier'
  post '/modals/classifier/delete', to: 'classifier_schemes#deleteClassifier'

  resources :alert_conditions
  resources :displays
  resources :projects

  root to: "projects#index"

  post '/alertConditions/update', to: 'alert_conditions#massUpdate'
  post '/projects/:project_id/upload/gnu', to: 'projects#upload_gnu_pages'
  post '/projects/:project_id/upload/scale', to: 'projects#upload_scale_db'
  post '/projects/:project_id/upload/determinations', to: 'projects#upload_determinations'

  post '/change-scaife-mode', to: 'alert_conditions#changeSCAIFEMode' #expects contentType: 'application/json'
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

Caball::Application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'

  root :to => 'home#index'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  resources :after_signup
  resources :accounts
  resources :milestones
  resources :disputes

  devise_for :filmmakers, :controllers => { :omniauth_callbacks => "filmmakers/omniauth_callbacks",:registrations => "filmmakers/registrations" , :sessions => "filmmakers/sessions" }
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :registrations => "users/registrations", :sessions => "users/sessions"}
  devise_for :clients#, :controllers => { :omniauth_callbacks => "clients/omniauth_callbacks", :registrations => "clients/registrations", :sessions => "clients/sessions"}

  # match '/filmmakers/sign_up'        => 'filmmakers#new', :user => { :meta_type => 'filmmaker' }
  match '/filmmakers'            => 'filmmakers#index'
  match '/filmmakers/dashboard'      => 'filmmakers/dashboard#index'
  match '/filmmakers/settings'       => 'filmmakers/dashboard#settings'
  match '/filmmakers/profile'        => 'filmmakers/profile#index'
  match '/filmmakers/accounts'       => 'filmmakers/accounts#index'
  match '/filmmakers/projects'       => 'filmmakers/projects#index'

  match '/accept_proposal/:proposal_id' => 'filmmakers/projects#accept_updated_proposal', :as => 'filmmaker_accept_project_proposal'
  match '/decline_proposal/:proposal_id' => 'filmmakers/projects#decline_updated_proposal', :as => 'filmmaker_decline_project_proposal'
  match '/edit_updated_proposal/:proposal_id' => 'filmmakers/projects#edit_updated_proposal', :as => 'filmmaker_edit_project_proposal'

	match '/filmmakers/:project_id/feedback' => 'filmmakers/feedback#index', :as => 'feedback_filmmaker_project'
  match '/clients/:project_id/feedback/:filmmaker_id'    => 'filmmakers/feedback#index', :as => 'feedback_client_project'

  match '/filmmakers/messages'       => 'filmmakers/conversations#index'
  match '/filmmakers/messages/new'   => 'filmmakers/conversations#create'
  get '/filmmakers/messages/:id/trash'   => 'filmmakers/conversations#trash', :as => 'filmmaker_message_trash'
  get '/filmmakers/messages/:id/untrash'   => 'filmmakers/conversations#untrash', :as => 'filmmaker_message_untrash'
  get '/filmmakers/messages/:id'   => 'filmmakers/conversations#show', :as => 'filmmaker_message'
  match '/filmmakers/messages/:id/reply' => 'filmmakers/conversations#reply', :as => 'filmmaker_message_reply'

  match '/filmmakers/disputes'       => 'disputes#index'
  match '/filmmakers/disputedetails' => 'disputes#disputedetails'
  match '/filmmakers/filmmaker-selection' => 'filmmakers/profile#filmmaker-selection'
  match '/filmmakers/portfolio'      => 'filmmakers/after_signup#portfolio'
  match '/filmmakers/blacklist_project' => 'filmmakers/dashboard#blacklist_project'
  match '/filmmakers/switch_pro'				 => 'filmmakers/dashboard#switch_pro'
  match '/fimmakers/submit_proposal'		=> 'filmmakers#submit_proposal', :as => 'submit_proposal'
 # match '/fimmakers/modify_project_proposal'		=> 'filmmakers#modify_project_proposal', :as => 'modify_project_proposal'
  match '/filmmakers/submit_feedback'   => 'filmmakers/feedback#submit_feedback', :as => 'submit_feedback'
  match '/filmmakers/milestones'     => 'milestones#show'
  match '/filmmakers/search'          => 'filmmakers#index', :as => :filmmaker_search
  match 'filmmakers/search_messages' => 'filmmakers#search_messages', :as => 'filmmaker_messages_search'
  match '/filmmakers/hire'           => 'filmmakers/profile#filmmaker_selection', :as => :filmmaker_selection
  match '/filmmakers/change_password' => 'filmmakers/dashboard#change_password'
  match '/filmmakers/change_email'   => 'filmmakers/dashboard#change_email'
  match '/filmmakers/change_email_settings' => 'filmmakers/dashboard#change_email_settings'
  match '/filmmakers/change_company_settings' => 'filmmakers/dashboard#change_company_settings'
  match '/filmmakers/upgrade'				 => 'filmmakers/dashboard#upgrade'

  match '/clients/create_direct_hire_proposal' => 'clients#create_direct_hire_proposal', :as => 'direct_hire_proposal'

  # match '/clients/sign_up'           => 'clients#new', :user => { :meta_type => 'client' }
  match '/clients/search_messages'   => 'clients#search_messages', :as => 'client_messages_search'
  get   '/clients/sign_in'           => 'clients/sessions#new'
  match '/clients/step_1'            => 'clients#step_1'
  match '/clients/step_2'            => 'clients#step_2'
  match '/clients/step_3'            => 'clients#step_3'
  match '/clients/dashboard'         => 'clients/dashboard#index'
  match '/clients/profile'           => 'clients/profile#index'
  match '/clients/accounts'          => 'clients/accounts#index'
  match '/clients/projects'          => 'clients/projects#index'
  match '/clients/settings'          => 'clients/dashboard#settings'
  match '/clients/messages'          => 'clients/conversations#index'
  match '/clients/messages/new'      => 'clients/conversations#create'
  get '/clients/messages/:id/trash'   => 'clients/conversations#trash', :as => 'client_message_trash'
  get '/clients/messages/:id/untrash'   => 'clients/conversations#untrash', :as => 'client_message_untrash'
  post '/clients/messages/:id/reply'   => 'clients/conversations#reply', :as => 'client_message_reply'
  get '/clients/messages/:id/delete_permanently'   => 'clients/conversations#delete_permanently', :as => 'client_message_delete_permanently'
  get '/clients/message/:message_id' => 'clients/conversations#show', :as => 'client_message_show'
  match '/clients/disputes'          => 'disputes#index'
  match '/clients/create-project'    => 'clients/dashboard#create_project'
  match '/clients/disputedetails'    => 'disputes#disputedetails'
  match '/clients/switch_pro'				 => 'clients/dashboard#switch_pro'
  match '/clients/release_payment'   => 'clients/projects#release_payment'
  match '/clients/milestones'        => 'milestones#index'
  match '/escrow/:milestone_id'      => 'clients/projects#escrow_milestone_funds', :as => :escrow
  match '/clients/download_proposal_attachment/:proposal_id' => 'clients/projects#download_attachment', :as => 'download_proposal_attachment'
  match '/auth/:provider/callback'   => 'clients/sessions#create'

  match '/clients/add-bank-account'    => 'clients/accounts#add_bank_account'
  match '/clients/add-credit-card'    => 'clients/accounts#add_credit_card'
  match '/clients/create_bank_account' => 'clients/accounts#create_balanced_bank_account'
  match '/clients/create_credit_card' => 'clients/accounts#create_balanced_credit_card'

  match '/filmmakers/add-bank-account'    => 'filmmakers/accounts#add_bank_account'
  match '/filmmakers/add-credit-card'    => 'filmmakers/accounts#add_credit_card'
  match '/filmmakers/create_bank_account' => 'filmmakers/accounts#create_balanced_bank_account'
  match '/filmmakers/create_credit_card' => 'filmmakers/accounts#create_balanced_credit_card'


  match '/clients/change_password'   => 'clients/dashboard#change_password'
  match '/clients/change_email'      => 'clients/dashboard#change_email'
  match '/clients/change_email_settings' => 'clients/dashboard#change_email_settings'

  get "activities/index"

  match '/users/select_user' => 'static_pages#select_user'
  match '/our_team' => 'static_pages#team'
  match '/our_mission' => 'static_pages#mission'
  match '/about' => 'static_pages#about_us'
  match '/contact' => 'contact_us/contacts#new'
  match '/contact_us' => 'contact_us/contacts#new'
  match '/faq' => 'static_pages#faq'
  match '/FAQ' => 'static_pages#faq'

  # get 'people', to: 'users#index', via: :all
  resources :users, :path => "people"

  match '/people/:id' => 'filmmakers#update', :via => 'post'
  #match "/blog(/*path)" => redirect{ |env, req| "http://blog.filmzu.com" + (req.path ? "#{req.path}" : '/')}

  match 'check_url_param' => 'application#check_url_param'

  match "/main_search" => 'application#main_search'

  match 'users/recommended_projects' => 'users#next_recommended_projects'
  match 'users/recommended_people' => 'users#next_recommended_people'
  match 'users/recommended_events' => 'users#next_recommended_events'

  match '/users/set_notification_check_time' => 'users#set_notification_check_time'

  match '/users/update' => 'users#custom_update', :via => 'POST'
  match '/users/step_1' => 'users#step_1'

  match '/users/step_1_reload' => 'users#step_1_reload'
  match '/users/step_2' => 'users#step_2'
  match '/users/step_3' => 'users#step_3'
  match '/users/files_upload' => 'users#files_upload'
  match '/users/agent_names' => 'users#agent_names'
  match '/users/profile' => 'users#profile'
  match '/users/change_password' => 'users#change_password'
  match '/users/change_email' => 'users#change_email'
  match '/users/change_email_settings' => 'users#change_email_settings'
  get '/users/search_by_name'

  match '/events/files_upload' => 'events#files_upload'
  match '/projects/files_upload' => 'projects#files_upload'
  match '/comments/files_upload' => 'comments#files_upload'
  #match '/blogs/files_upload' => 'blogs#files_upload'
  match '/projects/modify_project_proposal'		=> 'projects#modify_project_proposal', :as => 'modify_project_proposal'

   resources :filmmakers do
     resources :conversations , :photos
   end

   resources :clients do
     resources :conversations , :photos
   end

  resources :users do
    resources :characteristics, :photos, :talents, :profile#, :blogs
  end


  match '/roles/destroy' => 'roles#destroy', :via => 'POST'


  match '/projects/step_1'          => 'projects#step_1'
  match '/projects/step_2'          => 'projects#step_2'
  match '/projects/step_3'          => 'projects#step_3'
  match '/projects/add_filled_role' => 'projects#add_filled_role'
	match '/projects/view/:project_id'	=> 'projects#view_project', :as => 'view_project'
	match '/projects/proposal-submitted'    => 'filmmakers/dashboard#proposal_submitted', :as => :proposal_submitted
	match '/projects/proposal-submitted1'    => 'filmmakers/dashboard#proposal_submitted1'
  match '/projects/search'          => 'projects#index', :as => :project_search
  resources :projects do
    resources :comments
  end

  #match '/blogs/:id' => 'blogs#update', :via => 'POST'
  #resources :blogs
  # post request to handle comment handle
  match '/comments/:id' => 'comments#update', :via => 'POST'
  resources :comments
  match 'conversations/get_messages' => 'conversations#get_messages', :via => 'GET'
  match '/conversations/empty_trash' => 'conversations#empty_trash', :via => 'POST'
  resources :conversations
  match 'conversations/send-generic-message' => 'conversations#send_message_generic', :via => 'POST'

  resources :notifications
  resources :friendships
  match 'friendships/destroy' => 'friendships#destroy', :via => 'POST'
  resources :likes
  match 'likes/unlike' => 'likes#unlike', :via => 'POST'

  resources :endorsements

  resources :role_applications do
    get :already_approved
  end
  match 'roles_applicants' => 'roles#applicants_list', :via => 'POST'
  match 'role_applications/approve' => 'role_applications#approve', :via => 'POST'
  match 'role_applications/un_approve' => 'role_applications#un_approve', :via => 'POST'

  match 'report' => 'application#report'

  # News feed
  match 'activities/load_more' => 'activities#next_activities'
  resources :activities


  # Static Pages

  resources :home, except: :show
  %w[privacy terms team mission opportunities faq glossary labs beta skills filmmaker_protection client_protection about_us].each do |page|
    get page, controller: 'static_pages', action: page
  end

  # match 'dashboard'                 => 'users#dashboard'
  match 'dashboard/projects'        => 'users#dashboard_projects', :via => 'GET'
  match 'dashboard/events'          => 'users#dashboard_events', :via => 'GET'
  match 'dashboard/conversations'   => 'users#dashboard_conversations', :via => 'GET'
  match '/dashboard/manage_project' => 'users#manage_project', :via => 'GET'


  match 'projects/show' => 'projects#show'
  # match 'auth/:provider/callback', to: 'sessions#create'
  match 'auth/failure', to: redirect('/')
  match 'signout', to: 'sessions#destroy', as: 'signout'
  match 'clients_signout', to: 'clients/sessions#destroy', as: 'client_signout'
  match 'filmmakers_signout', to: 'filmmakers/sessions#destroy', as: 'filmmaker_signout'

  # Admin Area (older version)
  #namespace :admin do
  #  %w[index users user_images interrogate projects project_images events event_images messages interface buttons calendar charts chat gallery grid invoice login tables widgets form_wizard form_common form_validation ].each do |page|
  #    get 'admin/' + page
  #  end
  #  put 'admin/update_user'
  #  put 'admin/update_project'
  #end

  resources :conversations, only: [:index, :show, :new, :create] do
    member do
      post :reply
      post :trash
      post :untrash
      post :unread
      post :read
    end
  end

  namespace :api do
    namespace :v1 do
        resources :filmmakers, only: :index
    end
  end

	match '/clients/projects/create_project'=> 'clients/projects#create'
  match '/clients/projects/:id/message_participants'=> 'clients/projects#message_participants'
  post  '/clients/projects/send_messages' => 'clients/projects#send_messages'
	match 'projects/create_project'=> 'clients#store_project_data'

	match '/search_location.json' => 'application#search_location'
	match '/clients/dashboard/switch_pro' => 'clients/dashboard#switch_pro', :via => [:get, :post]

	# routes for direct hire module
	match '/direct_hires/accept_proposal/:proposal_id' => 'direct_hires#accept_proposal'
	match '/direct_hires/prompt_decline_proposal/:proposal_id' => 'direct_hires#prompt_decline_proposal'
	match '/direct_hires/decline_proposal/:proposal_id' => 'direct_hires#decline_proposal'

	match '/view_proposals/:project_id' => 'clients/projects#index', :as => 'project_proposals'
	match '/hire_proposal/:proposal_id' => 'clients/projects#hire_proposal', :as => 'hire_proposal'
	match '/remove_proposal/:proposal_id' => 'clients/projects#remove_proposal', :as => 'remove_proposal'
  match '/accept_project_proposal/:proposal_id' => 'clients/projects#accept_project_proposal', :as => 'client_accept_project_proposal'
  match '/decline_project_proposal/:proposal_id' => 'clients/projects#decline_project_proposal', :as => 'client_decline_project_proposal'
  match '/edit_project_proposal/:proposal_id' => 'clients/projects#edit_proposal', :as => 'client_edit_project_proposal'
  match '/clients/hire_filmmaker/:proposal_id' => 'clients/projects#hire_filmmaker', :as => 'hire_filmmaker'

  post '/clients/accounts/set_default_account' => 'clients/accounts#set_default_account', :as => 'client_set_default_account'
  post '/clients/accounts/set_default_backup_account' => 'clients/accounts#set_default_backup_account', :as => 'client_set_default_backup_account'
  get '/clients/accounts/remove_client_credit_card/:id' => 'clients/accounts#remove_client_credit_card', :as => 'remove_client_credit_card'
  get '/clients/accounts/remove_client_bank_account/:id' => 'clients/accounts#remove_client_bank_account', :as => 'remove_client_bank_account'

  post '/filmmakers/accounts/set_default_account' => 'filmmakers/accounts#set_default_account', :as => 'filmmaker_set_default_account'
  post '/filmmakers/accounts/set_default_backup_account' => 'filmmakers/accounts#set_default_backup_account', :as => 'filmmaker_set_default_backup_account'
  get '/filmmakers/accounts/remove_filmmaker_credit_card/:id' => 'filmmakers/accounts#remove_filmmaker_credit_card', :as => 'remove_filmmaker_credit_card'
  get '/filmmakers/accounts/remove_filmmaker_bank_account/:id' => 'filmmakers/accounts#remove_filmmaker_bank_account', :as => 'remove_filmmaker_bank_account'

  get '/clients/accounts/add_fund' => 'clients/accounts#add_fund', as: 'client_add_fund'
  post '/clients/accounts/client_deposit_fund' => 'clients/accounts#client_deposit_fund', as: 'client_deposit_fund'

  get '/clients/accounts/verify_bank_account_popup/:id' =>
      'clients/accounts#verify_bank_account_popup',
      as: 'client_verify_bank_account_popup'

  post '/clients/accounts/verify_bank_account/:id' =>
       'clients/accounts#verify_bank_account',
       as: 'client_verify_bank_account'

  get '/filmmakers/accounts/verify_bank_account_popup/:id' =>
      'filmmakers/accounts#verify_bank_account_popup',
      as: 'filmmaker_verify_bank_account_popup'

  post '/filmmakers/accounts/verify_bank_account/:id' =>
      'filmmakers/accounts#verify_bank_account',
      as: 'filmmaker_verify_bank_account'

  get '/filmmakers/accounts/withdraw_fund_popup' =>
      'filmmakers/accounts#withdraw_fund_popup',
      as: 'filmmaker_withdraw_fund_popup'

  post '/filmmakers/accounts/withdraw_fund' =>
       'filmmakers/accounts#withdraw_fund',
       as: 'filmmaker_withdraw_fund'

  get '/filmmaker/proposals/(:proposal_id)' =>
      'filmmakers/projects#filmmaker_proposals',
      as: 'filmmaker_proposals'

  match '/projects/download_additional_docs/:project_id' =>
        'projects#download_additional_docs',
        as: 'additional_docs_download'

  get '/clients/accounts/transactions' => 'clients/accounts#transactions', as: 'client_transactions'
  get '/filmmakers/accounts/transactions' => 'filmmakers/accounts#transactions', as: 'filmmaker_transactions'

  get '/clients/accounts/feature_project/:id' => 'clients/accounts#feature_project', as: 'client_feature_project'

  match '/clients/release_direct_hire_payment/:id' => 'clients/projects#release_direct_hire_payment', as: 'client_release_direct_hire_payment'

  match '/clients/fund_escrow_direct_hire_milestone/:id' => 'clients/projects#fund_escrow_direct_hire_milestone', as: 'client_fund_escrow_direct_hire_milestone'
  match '/clients/release_payment_direct_hire_milestone/:id' => 'clients/projects#release_payment_direct_hire_milestone', as: 'client_release_payment_direct_hire_milestone'

  match '/clients/fund_escrow_updated_milestone/:id' => 'clients/projects#fund_escrow_updated_milestone', as: 'client_fund_escrow_updated_milestone'
  match '/clients/release_payment_updated_milestone/:id' => 'clients/projects#release_payment_updated_milestone', as: 'client_release_payment_updated_milestone'
  mount Monologue::Engine, at: '/blog'
  Monologue::Engine.routes.draw do
    delete '/monologue/comments/:id', to: 'admin/comments#destroy', as: 'admin_monologue_comments'
    put '/monologue/comments/:id', to: 'admin/comments#update', as: 'admin_monologue_comments'
  end
end

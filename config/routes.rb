Rails.application.routes.draw do

  scope '/compliance' do
    resources :arf_reports, :only => [:index, :show, :destroy],
              :as => :scaptimony_arf_reports, :controller => :scaptimony_arf_reports do
      member do
        match 'parse', :to => 'scaptimony_arf_reports#parse'
      end
      collection do
        get 'auto_complete_search'
      end
    end
    match 'dashboard', :to => 'scaptimony_dashboard#index', :as => "scaptimony_dashboard"
    resources :policies, :only => [:index, :new, :show, :create, :edit, :update, :destroy],
              :as => :scaptimony_policies, :controller => :scaptimony_policies do
      member do
        match 'parse', :to => 'scaptimony_policies#parse'
        match 'dashboard', :to => 'scaptimony_policy_dashboard#index', :as => 'scaptimony_policy_dashboard'
      end
      collection do
        get 'auto_complete_search'
        post 'scap_content_selected'
        get 'select_multiple_hosts'
        post 'update_multiple_hosts'
        get 'disassociate_multiple_hosts'
        post 'remove_policy_from_multiple_hosts'
      end
    end
    resources :scap_contents,
              :as => :scaptimony_scap_contents, :controller => :scaptimony_scap_contents do
      collection do
        get 'auto_complete_search'
      end
    end
    resources :hosts, :only => [:show], :as => :scaptimony_hosts, :controller => :scaptimony_hosts
  end

  namespace :api do
    scope "(:apiv)", :module => :v2, :defaults => {:apiv => 'v2'},
          :apiv => /v1|v2/, :constraints => ApiConstraints.new(:version => 2) do
      resources :scap_contents, :except => [:new, :edit]
      resources :policies, :except => [:new, :edit]
      resources :arf_reports, :only => [:index, :show, :destroy]
      namespace :compliance do
        post 'arf_reports/:cname/:policy_id/:date', \
              :constraints => { :cname => /[^\/]+/ }, :to => 'arf_reports#create'
      end
    end
  end
end

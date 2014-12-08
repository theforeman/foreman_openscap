Rails.application.routes.draw do

  scope '/compliance' do
    resources :arf_reports, :only => [:index, :show, :destroy],
              :as => :scaptimony_arf_reports, :controller => :scaptimony_arf_reports
    match 'dashboard', :to => 'scaptimony_dashboard#index', :as => "scaptimony_dashboard"
    resources :policies, :only => [:index, :new, :show, :create, :edit, :update, :destroy],
              :as => :scaptimony_policies, :controller => :scaptimony_policies do
      member do
        match 'dashboard', :to => 'scaptimony_policy_dashboard#index', :as => 'scaptimony_policy_dashboard'
      end
      collection do
        post 'scap_content_selected'
        get 'select_multiple_hosts'
        post 'update_multiple_hosts'
      end
    end
    resources :scap_contents, :only => [:index, :show, :new, :create, :edit, :update],
      :as => :scaptimony_scap_contents, :controller => :scaptimony_scap_contents
  end

  namespace :api do
    scope "(:apiv)", :module => :v2, :defaults => {:apiv => 'v2'},
          :apiv => /v1|v2/, :constraints => ApiConstraints.new(:version => 2) do
      namespace :openscap do
        post 'arf_reports/:cname/:policy/:date', \
              :constraints => { :cname => /[^\/]+/ }, :to => 'arf_reports#create'
      end
    end
  end
end

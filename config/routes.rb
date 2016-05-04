Rails.application.routes.draw do

  scope '/compliance' do

    resources :arf_reports, :only => [:index, :show, :destroy] do
      member do
        get 'show_html'
        get 'parse_html'
        get 'parse_bzip'
      end
      collection do
        get 'auto_complete_search'
        get 'delete_multiple'
        post 'submit_delete_multiple'
      end
    end

    get 'dashboard', :to => 'compliance_dashboard#index', :as => "compliance_dashboard"

    resources :policies, :only => [:index, :new, :show, :create, :edit, :update, :destroy] do
      member do
        get 'parse', :to => 'policies#parse'
        get 'dashboard', :to => 'policy_dashboard#index', :as => 'policy_dashboard'
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

    resources :scap_contents do
      collection do
        get 'auto_complete_search'
      end
    end

    resources :hosts, :only => [:show], :as => :compliance_hosts, :controller => :compliance_hosts
  end

  namespace :api do
    scope "(:apiv)", :module => :v2, :defaults => {:apiv => 'v2'},
          :apiv => /v1|v2/, :constraints => ApiConstraints.new(:version => 2) do
      namespace :compliance do
        resources :scap_contents, :except => [:new, :edit] do
          member do
            get 'xml'
          end
        end
        resources :policies, :except => [:new, :edit] do
          member do
            get 'content'
          end
        end
        resources :arf_reports, :only => [:index, :show, :destroy]
        post 'arf_reports/:cname/:policy_id/:date', \
              :constraints => { :cname => /[^\/]+/ }, :to => 'arf_reports#create'
      end
    end
  end
end

Foreman::Application.routes.draw do
  resources :hosts do
    collection do
      post 'openscap_proxy_changed'
    end
  end

  resources :hostgroups do
    collection do
      post 'openscap_proxy_changed'
    end
  end
end

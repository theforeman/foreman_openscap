Rails.application.routes.draw do

  resources :arf_reports, :only => [:index, :show, :destroy] do
  end
  resources :scaptimony_policies, :only => [:index, :new, :show, :create, :edit, :update, :destroy] do
    collection do
      post 'scap_content_selected'
    end
  end
  resources :scaptimony_scap_contents, :only => [:index, :show, :new, :create, :edit, :update] do
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

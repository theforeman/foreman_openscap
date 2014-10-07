Rails.application.routes.draw do

  match 'new_action', :to => 'foreman_openscap/hosts#new_action'

  namespace :api do
    scope "(:apiv)", :module => :v2, :defaults => {:apiv => 'v2'},
          :apiv => /v1|v2/, :constraints => ApiConstraints.new(:version => 2) do
      namespace :openscap do
        post 'arf/:cname/:policy/:date', \
              :constraints => { :cname => /[^\/]+/ }, :to => 'arf#create'
      end
    end
  end
end

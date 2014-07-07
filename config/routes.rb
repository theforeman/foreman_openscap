Rails.application.routes.draw do

  match 'new_action', :to => 'foreman_openscap/hosts#new_action'

end

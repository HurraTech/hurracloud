require 'resque/server'

Rails.application.routes.draw do
  get 'files/browse', to: 'files#browse', format: false
  get 'files/browse/:source_id', to: 'files#browse', format: false
  get 'files/browse/:source_id/*path', to: 'files#browse', format: false
  get 'files/:file_action/*path', to: 'files#proxy', format: false
  post 'files/:file_action/*path', to: 'files#proxy', format: false
  delete 'files/:file_action/*path', to: 'files#proxy', format: false
  put 'files/:file_action/*path', to: 'files#proxy', format: false

  get 'search', to: 'search#search', format: false

  resources :sources, :defaults => { :format => 'json' } do
    get '_mount', to: 'sources#mount'
    get '_unmount', to: 'sources#unmount'
  end

  resources :google_drive_accounts,  format: false
  
  resources :indices, :defaults => { :format => 'json' } do
    resources :index_segments,  :defaults => { :format => 'json' }
    get '_pause', to: 'indices#pause'
    get '_resume', to: 'indices#resume'
    get '_delete', to: 'indices#delete'
    get '_cancel', to: 'indices#cancel'
  end

  resources :apps, :param => :auid, :defaults => { :format => 'json' } do
    post '_install', to: 'apps#install'
    post '_start', to: 'apps#start'
    post '/:container/_exec', to: 'apps#exec'
    resources :app_commands, :defaults => { :format => 'json' }
  end
  mount Resque::Server.new, at: "/resque"

end

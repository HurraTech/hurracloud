require 'resque/server'

Rails.application.routes.draw do
  get 'files/browse', to: 'files#browse', format: false
  get 'files/browse/:source_id/:partition_label', to: 'files#browse', format: false
  get 'files/browse/:source_id/:partition_label/*path', to: 'files#browse', format: false
  get 'files/:file_action/*path', to: 'files#proxy', format: false
  post 'files/:file_action/*path', to: 'files#proxy', format: false
  delete 'files/:file_action/*path', to: 'files#proxy', format: false
  put 'files/:file_action/*path', to: 'files#proxy', format: false

  get 'search', to: 'search#search', format: false

  resources :sources, :defaults => { :format => 'json' } do
    get '_mount/:partition_id', to: 'sources#mount_partition'
    get '_unmount/:partition_id', to: 'sources#unmount_partition'
  end
  resources :indices, :defaults => { :format => 'json' } do
    resources :index_segments,  :defaults => { :format => 'json' }
    get '_pause', to: 'indices#pause'
    get '_resume', to: 'indices#resume'
  end

  mount Resque::Server.new, at: "/resque"

end

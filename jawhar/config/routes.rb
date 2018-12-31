Rails.application.routes.draw do
  get 'files/:file_action/*path', to: 'files#proxy', format: false
  post 'files/:file_action/*path', to: 'files#proxy', format: false
  delete 'files/:file_action/*path', to: 'files#proxy', format: false
  put 'files/:file_action/*path', to: 'files#proxy', format: false

  resources :sources, :defaults => { :format => 'json' }
  resources :indices, :defaults => { :format => 'json' } do
    resources :index_segments,  :defaults => { :format => 'json' }
  end
end

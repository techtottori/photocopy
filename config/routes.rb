Rails.application.routes.draw do
  get 'profile/edit', to:'users#edit', as: :profile_edit
  get 'profile/(:id)', to:'users#show', as: :profile
  get '', to: 'users#top'
  get 'top', to:'users#top', as: :top
  get 'follower_list/(:id)', to:'users#follower_list', as: :follower_list
  get 'follow/(:id)', to:'users#follow', as: :follow
  get 'follow_list/(:id)', to:'users#follow_list', as: :follow_list
  get 'sign_up', to:'users#sign_up', as: :sign_up
  get 'sign_in', to:'users#sign_in', as: :sign_in
  get 'sign_out', to:'users#sign_out', as: :sign_out
  get 'profile/(:id)', to:'users#show'
  post 'sign_up', to:'users#sign_up_process'
  post 'sign_in', to:'users#sign_in_process'
  post 'posts', to:'posts#create'
  post 'profile/edit', to:'users#update'
  resources :posts do
    member do
      #いいね
      get 'like', to: 'posts#like', as: :like
      post 'comment', to: 'posts#comment'
    end
  end
end
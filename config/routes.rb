require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "landing#index"

  namespace :admin do
    namespace :competitor_monitoring do
      resources :promotions, only: [ :index, :show ]
      resources :reports,    only: [ :index, :show, :create ]
      resources :competitors do
        resources :monitoring_sources, only: [] do
          member { post :fetch }
          resources :instagram_posts,  only: [ :index ]
          resources :source_snapshots, only: [ :index, :show ]
        end
      end
    end
  end
end

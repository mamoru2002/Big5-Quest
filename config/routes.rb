Rails.application.routes.draw do
  namespace :api do
    resources :diagnosis_results, only: [ :create, :show ] do
      member do
        post :answers
        post :complete
      end
    end

    resources :diagnosis_forms, only: [], param: :name do
      member { get :questions }
    end

    resources :user_challenges, only: [ :index, :create, :update ]

    resources :traits, only: [], param: :code do
      resources :challenges, only: [ :index ], module: :traits
    end

    get "weeks/current", to: "weeks#current"
    get "weeks/:offset", to: "weeks#show"
  end
end

Rails.application.routes.draw do
  namespace :api do
    resources :diagnosis_results, only: [ :create, :show, :update ] do
      member do
        post :answers
        post :complete
      end
    end
    resources :diagnosis_forms, only: [], param: :name do
      member { get :questions }
    end
    resources :user_challenges, only: [ :create ]

    resources :traits, only: [], param: :code do
      resources :challenges, only: [ :index ], module: :traits
      #           └ app/controllers/api/traits/challenges_controller.rb
    end
  end
end

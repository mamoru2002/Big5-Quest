Rails.application.routes.draw do
  namespace :api do
      resources :diagnosis_results, only: [ :create ] do
    member do
        post :answers
        post :complete
      end
    end

    resources :diagnosis_forms, only: [], param: :name do
      member { get :questions }
    end
  end
end

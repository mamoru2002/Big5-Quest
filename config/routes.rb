Rails.application.routes.draw do
namespace :api do
    resources :diagnosis_forms, only: [] do
      member { get :questions }
    end
  end
end

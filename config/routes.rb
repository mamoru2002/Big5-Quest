Rails.application.routes.draw do
  get "/up", to: proc { [ 200, { "Content-Type" => "text/plain" }, [ "ok" ] ] }
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

    resources :emotion_tags, only: [ :index ]

    get "weeks/current", to: "weeks#current"
    get "weeks/:offset", to: "weeks#show", constraints: { offset: /-?\d+/ }
  end
end

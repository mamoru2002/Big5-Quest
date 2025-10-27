Rails.application.routes.draw do
  get "/up", to: proc { [ 200, { "Content-Type" => "text/plain" }, [ "ok" ] ] }

  namespace :api, defaults: { format: :json } do
    devise_for :user_credentials,
               class_name: "UserCredential",
               path: "",
               skip: %i[sessions registrations passwords confirmations]

    devise_scope :api_user_credential do
      post   "login",            to: "auth/sessions#create"
      delete "logout",           to: "auth/sessions#destroy"
      post   "sign_up",          to: "auth/registrations#create"
      get    "me",               to: "auth/sessions#me"
      post   "auth/guest_login", to: "auth/guests#create"
      get  "confirmation", to: "auth/confirmations#show",   as: :api_user_credential_confirmation
      post "confirmation", to: "auth/confirmations#create", as: :api_confirmation
    end

    namespace :auth do
      post "passwords", to: "passwords#create"
      put  "passwords", to: "passwords#update"
    end

    resources :diagnosis_results, only: %i[create show] do
      member do
        put  :responses
        post :complete
      end
    end

    resources :diagnosis_forms, only: [], param: :name do
      member { get :questions }
    end

    resources :user_challenges, only: %i[index create update]

    resources :traits, only: [], param: :code do
      resources :challenges, only: [ :index ], module: :traits
    end

    resources :emotion_tags, only: [ :index ]

    get "weeks/current", to: "weeks#current"
    get "weeks/:offset", to: "weeks#show", constraints: { offset: /-?\d+/ }

    get "stats/summary",       to: "stats#summary"
    get "stats/trait_history", to: "stats#trait_history"

    get   "week_skips/status", to: "week_skips#status"
    patch "week_skips",        to: "week_skips#update"

    resource :profile, only: [ :show, :update ]
  end
end

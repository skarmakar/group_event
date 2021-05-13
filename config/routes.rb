Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      defaults format: :json do
        resources :group_events, except: [:new, :edit]
      end
    end
  end
end

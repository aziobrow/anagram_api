Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :words, param: :word, only: [:create, :destroy] do
        collection do
          delete :destroy
          get :analytics
        end
      end

      resources :anagrams, param: :word, only: [:show] do
        collection do
          get :top_results
          get :verify_set
        end

        delete :destroy, on: :member
      end
    end
  end
end

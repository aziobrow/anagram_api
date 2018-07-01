Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :words, param: :word, only: [:create, :destroy] do
        collection do
          delete :destroy
        end
      end

      resources :anagrams, param: :word, only: [:show]
    end
  end
end

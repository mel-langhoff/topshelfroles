Rails.application.routes.draw do
  root "job_postings#index"

  resources :job_postings, only: [:index, :show]
end
Rails.application.routes.draw do
  root "job_postings#index"

  post "jobs/refresh", to: "job_postings#refresh"

  resources :job_postings, only: [:index, :show, :update] do
    member do
      get :resume_pdf
      get :analyze
    end
  end
end
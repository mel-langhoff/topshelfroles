Rails.application.routes.draw do
  root "job_postings#index"

  post "jobs/refresh", to: "job_postings#refresh"

  resources :job_postings, only: [:index, :show, :update] do
    member do
      get :resume_pdf
      get :analyze
      get :resume
    get :cover_letter
    get :download_resume
    end
  end
end
Rails.application.routes.draw do
  # Health check
  get '/up', to: proc { [200, {}, ['OK']] }

  namespace :api do
    # Authentication routes
    post 'auth/register', to: 'auth/registrations#create'
    post 'auth/login', to: 'auth/sessions#create'
    delete 'auth/logout', to: 'auth/sessions#destroy'
    get 'auth/me', to: 'auth/sessions#show'
    post 'auth/change-password', to: 'auth/password_changes#create'
    post 'auth/forgot-password', to: 'auth/password_resets#create'
    post 'auth/reset-password', to: 'auth/password_resets#update'
    get 'auth/tokens', to: 'auth/tokens#index'
    delete 'auth/tokens', to: 'auth/tokens#destroy'
    delete 'auth/tokens/:id', to: 'auth/tokens#destroy'
  end

  # Root route
  root to: proc { [200, { 'Content-Type' => 'application/json' }, [{ status: 'ok', message: 'UniOne API' }.to_json]] }
end

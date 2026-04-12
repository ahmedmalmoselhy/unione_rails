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

    # Shared routes
    get 'announcements', to: 'announcements#index'
    get 'announcements/:id', to: 'announcements#show'
    post 'announcements/:id/read', to: 'announcements#mark_read'
    
    get 'notifications', to: 'notifications#index'
    post 'notifications/read-all', to: 'notifications#mark_all_read'
    post 'notifications/:id/read', to: 'notifications#mark_read'
    delete 'notifications/:id', to: 'notifications#destroy'

    # Admin routes
    namespace :admin do
      resources :universities, except: [:new, :edit]
      resources :faculties, except: [:new, :edit]
      resources :departments, except: [:new, :edit]
      resources :courses, except: [:new, :edit]
      resources :academic_terms, except: [:new, :edit], path: 'terms'
      
      resources :webhooks, except: [:new, :edit] do
        get 'deliveries', on: :member
      end
    end
  end

  # Root route
  root to: proc { [200, { 'Content-Type' => 'application/json' }, [{ status: 'ok', message: 'UniOne-API' }.to_json]] }
end

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

    # Student portal routes
    namespace :student do
      get 'profile', to: 'profile#show'
      patch 'profile', to: 'profile#update'
      
      get 'enrollments', to: 'enrollments#index'
      post 'enrollments', to: 'enrollments#create'
      delete 'enrollments/:id', to: 'enrollments#destroy'
      
      get 'grades', to: 'grades#index'
      get 'grades/term/:term_id', to: 'grades#by_term', as: 'grades_by_term'
      
      get 'transcript', to: 'transcript#show'
      get 'transcript/pdf', to: 'transcript_pdf#show'
      get 'academic-history', to: 'transcript#academic_history'
      
      get 'schedule', to: 'schedule#show'
      get 'schedule/ics', to: 'schedule#ics'
      
      get 'attendance', to: 'attendance#index'
      get 'attendance/section/:section_id', to: 'attendance#by_section', as: 'attendance_by_section'
      
      get 'ratings', to: 'ratings#index'
      post 'ratings', to: 'ratings#create'
      
      get 'waitlist', to: 'waitlist#index'
      post 'waitlist', to: 'waitlist#create'
      delete 'waitlist/:section_id', to: 'waitlist#destroy'
    end

    # Professor portal routes
    namespace :professor do
      get 'profile', to: 'profile#show'
      patch 'profile', to: 'profile#update'
      
      get 'sections', to: 'sections#index'
      get 'sections/:id', to: 'sections#show'
      get 'sections/:id/students', to: 'sections#students'
      get 'sections/:id/schedule', to: 'sections#schedule'
      
      get 'sections/:section_id/grades', to: 'grades#index'
      post 'sections/:section_id/grades', to: 'grades#create'
      patch 'sections/:section_id/grades/:id', to: 'grades#update'
      
      get 'sections/:section_id/attendance', to: 'attendance#index'
      get 'sections/:section_id/attendance/:session_id', to: 'attendance#show'
      post 'sections/:section_id/attendance', to: 'attendance#create'
      put 'sections/:section_id/attendance/:session_id', to: 'attendance#update'
      post 'sections/:section_id/attendance/:session_id/close', to: 'attendance#close'
      get 'sections/:section_id/attendance/statistics', to: 'attendance#statistics'
      
      get 'sections/:section_id/announcements', to: 'announcements#index'
      post 'sections/:section_id/announcements', to: 'announcements#create'
      patch 'sections/:section_id/announcements/:id', to: 'announcements#update'
      delete 'sections/:section_id/announcements/:id', to: 'announcements#destroy'
    end

    # Admin routes
    namespace :admin do
      # Dashboard
      get 'dashboard', to: 'dashboard#index'
      
      # User management
      resources :users, except: [:new, :edit] do
        member do
          post 'assign_role'
          post 'remove_role'
          post 'activate'
          post 'deactivate'
        end
        collection do
          get 'statistics'
        end
      end
      
      resources :universities, except: [:new, :edit]
      resources :faculties, except: [:new, :edit]
      resources :departments, except: [:new, :edit]
      resources :courses, except: [:new, :edit]
      resources :academic_terms, except: [:new, :edit], path: 'terms' do
        member do
          post 'activate'
          post 'deactivate'
        end
        collection do
          get 'current', to: 'academic_terms#current'
        end
      end
      
      resources :webhooks, except: [:new, :edit] do
        get 'deliveries', on: :member
      end
      
      resources :audit_logs, only: [:index, :show] do
        collection do
          get 'statistics'
        end
      end
    end
  end

  # Root route
  root to: proc { [200, { 'Content-Type' => 'application/json' }, [{ status: 'ok', message: 'UniOne-API' }.to_json]] }
end

Rails.application.routes.draw do
  # Health check
  get '/up', to: proc { [200, {}, ['OK']] }
  get '/api/health', to: 'api/health#show'
  get '/api/v1/health', to: 'api/health#show'

  # API v1 routes (versioned)
  namespace :api do
    namespace :v1 do
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

        # Section announcements
        get 'sections/:section_id/announcements', to: 'section_announcements#index'
        get 'sections/:section_id/announcements/:id', to: 'section_announcements#show'
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
        post 'sections/:section_id/grades/import', to: 'grades#import'
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

        # Professor schedule
        get 'schedule', to: 'sections#schedule'
        get 'schedule/ics', to: 'sections#ics', as: 'schedule_ics'
      end

      # Admin routes
      namespace :admin do
        # Dashboard
        get 'dashboard', to: 'dashboard#index'

        # Consolidated import API
        post 'imports/students', to: 'imports#students'
        post 'imports/grades', to: 'imports#grades'
        post 'imports/professors', to: 'imports#professors'
        get 'import-templates/students', to: 'imports#students_template'
        get 'import-templates/grades', to: 'imports#grades_template'

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

        # Academic management
        resources :students, except: [:new, :edit] do
          member do
            post 'activate'
            post 'deactivate'
            post 'graduate'
          end
          collection do
            get 'statistics'
            post 'import'
            get 'import_template'
          end
        end

        # Grade import via sections
        resources :sections, except: [:new, :edit] do
          collection do
            get 'statistics'
            post 'import_grades'
            get 'grades_import_template'
          end

          # Exam schedule management
          resource :exam_schedule, only: [:show, :create, :update], path: 'exam-schedule', controller: 'exam_schedules' do
            post :publish, on: :collection
          end

          # Teaching assistants
          resources :teaching_assistants, only: [:index, :create, :destroy], controller: 'section_teaching_assistants'

          # Group projects (nested under sections)
          resources :group_projects, only: [:index, :show, :create, :update, :destroy], controller: 'group_projects' do
            post 'members', to: 'group_projects#add_member', on: :member
            delete 'members/:member_id', to: 'group_projects#remove_member', on: :member
          end
        end

        resources :professors, except: [:new, :edit] do
          collection do
            get 'statistics'
          end
        end

        resources :employees, except: [:new, :edit]

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

    # Legacy API routes (backward compatibility - will be deprecated)
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

    get 'announcements', to: 'announcements#index'
    get 'announcements/:id', to: 'announcements#show'
    post 'announcements/:id/read', to: 'announcements#mark_read'

    get 'notifications', to: 'notifications#index'
    post 'notifications/read-all', to: 'notifications#mark_all_read'
    post 'notifications/:id/read', to: 'notifications#mark_read'
    delete 'notifications/:id', to: 'notifications#destroy'

    namespace :student do
      get 'profile', to: 'profile#show'
      patch 'profile', to: 'profile#update'
      get 'enrollments', to: 'enrollments#index'
      post 'enrollments', to: 'enrollments#create'
      delete 'enrollments/:id', to: 'enrollments#destroy'
      get 'grades', to: 'grades#index'
      get 'transcript', to: 'transcript#show'
      get 'transcript/pdf', to: 'transcript_pdf#show'
      get 'academic-history', to: 'transcript#academic_history'
      get 'schedule', to: 'schedule#show'
      get 'schedule/ics', to: 'schedule#ics'
      get 'attendance', to: 'attendance#index'
      get 'ratings', to: 'ratings#index'
      post 'ratings', to: 'ratings#create'
      get 'waitlist', to: 'waitlist#index'
      post 'waitlist', to: 'waitlist#create'
      delete 'waitlist/:section_id', to: 'waitlist#destroy'
      get 'sections/:section_id/announcements', to: 'section_announcements#index'
      get 'sections/:section_id/announcements/:id', to: 'section_announcements#show'
    end

    namespace :professor do
      get 'profile', to: 'profile#show'
      patch 'profile', to: 'profile#update'
      get 'sections', to: 'sections#index'
      get 'sections/:id', to: 'sections#show'
      get 'sections/:id/students', to: 'sections#students'
      get 'sections/:id/schedule', to: 'sections#schedule'
      get 'sections/:section_id/grades', to: 'grades#index'
      post 'sections/:section_id/grades', to: 'grades#create'
      post 'sections/:section_id/grades/import', to: 'grades#import'
      patch 'sections/:section_id/grades/:id', to: 'grades#update'
      get 'sections/:section_id/attendance', to: 'attendance#index'
      post 'sections/:section_id/attendance', to: 'attendance#create'
      get 'sections/:section_id/announcements', to: 'announcements#index'
      post 'sections/:section_id/announcements', to: 'announcements#create'
      patch 'sections/:section_id/announcements/:id', to: 'announcements#update'
      delete 'sections/:section_id/announcements/:id', to: 'announcements#destroy'
      get 'schedule', to: 'sections#schedule'
      get 'schedule/ics', to: 'sections#ics'
    end

    namespace :admin do
      get 'dashboard', to: 'dashboard#index'
      post 'imports/students', to: 'imports#students'
      post 'imports/grades', to: 'imports#grades'
      post 'imports/professors', to: 'imports#professors'
      get 'import-templates/students', to: 'imports#students_template'
      get 'import-templates/grades', to: 'imports#grades_template'
      resources :users, except: [:new, :edit]
      resources :students, except: [:new, :edit]
      resources :professors, except: [:new, :edit]
      resources :employees, except: [:new, :edit]
      resources :sections, except: [:new, :edit]
      resources :universities, except: [:new, :edit]
      resources :faculties, except: [:new, :edit]
      resources :departments, except: [:new, :edit]
      resources :courses, except: [:new, :edit]
      resources :academic_terms, except: [:new, :edit], path: 'terms'
      resources :webhooks, except: [:new, :edit]
      resources :audit_logs, only: [:index, :show]
    end
  end

  # Root route
  root to: proc { [200, { 'Content-Type' => 'application/json' }, [{ status: 'ok', message: 'UniOne-API', version: 'v1' }.to_json]] }
end

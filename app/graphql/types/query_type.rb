module Types
  class QueryType < BaseObject
    field :me, Types::UserType, null: true

    field :users, [Types::UserType], null: false do
      argument :role_slug, String, required: false
      argument :search, String, required: false
      argument :limit, Integer, required: false, default_value: 20
    end

    field :courses, [Types::CourseType], null: false do
      argument :active_only, Boolean, required: false, default_value: true
      argument :limit, Integer, required: false, default_value: 50
    end

    field :sections, [Types::SectionType], null: false do
      argument :academic_term_id, ID, required: false
      argument :course_id, ID, required: false
      argument :professor_id, ID, required: false
      argument :limit, Integer, required: false, default_value: 50
    end

    field :notifications, [Types::NotificationType], null: false do
      argument :limit, Integer, required: false, default_value: 20
    end

    def me
      context[:current_user]
    end

    def users(role_slug: nil, search: nil, limit: 20)
      require_admin!

      scope = ::User.includes(:roles, :student, :professor).order(created_at: :desc)
      scope = scope.joins(:roles).where(roles: { slug: role_slug }) if role_slug.present?

      if search.present?
        term = "%#{search}%"
        scope = scope.where(
          'users.email ILIKE ? OR users.first_name ILIKE ? OR users.last_name ILIKE ?',
          term, term, term
        )
      end

      scope.limit(limit)
    end

    def courses(active_only: true, limit: 50)
      scope = ::Course.order(code: :asc)
      scope = scope.where(is_active: true) if active_only
      scope.limit(limit)
    end

    def sections(academic_term_id: nil, course_id: nil, professor_id: nil, limit: 50)
      scope = ::Section.includes(:course, :professor, :academic_term).order(created_at: :desc)
      scope = scope.where(academic_term_id: academic_term_id) if academic_term_id.present?
      scope = scope.where(course_id: course_id) if course_id.present?
      scope = scope.where(professor_id: professor_id) if professor_id.present?
      scope.limit(limit)
    end

    def notifications(limit: 20)
      user = require_authenticated_user!
      user.notifications.order(created_at: :desc).limit(limit)
    end

    private

    def require_authenticated_user!
      user = context[:current_user]
      raise GraphQL::ExecutionError, 'Unauthorized' unless user

      user
    end

    def require_admin!
      user = require_authenticated_user!
      raise GraphQL::ExecutionError, 'Forbidden' unless user.admin?

      user
    end
  end
end

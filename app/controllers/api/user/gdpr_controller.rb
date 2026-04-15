module Api
  module User
    class GdprController < Api::BaseController
      def export
        render json: {
          success: true,
          data: {
            user: current_user.slice(:id, :email, :first_name, :last_name, :phone, :is_active, :created_at, :updated_at),
            roles: current_user.role_slugs,
            student_profile: current_user.student&.slice(:id, :student_number, :faculty_id, :department_id, :academic_year, :semester, :enrollment_status, :gpa),
            professor_profile: current_user.professor&.slice(:id, :staff_number, :department_id, :specialization, :academic_rank),
            employee_profile: current_user.employee&.slice(:id, :staff_number, :department_id, :position)
          }
        }, status: :ok
      end

      def anonymize
        unless ActiveModel::Type::Boolean.new.cast(params[:confirm])
          return render json: {
            success: false,
            error: 'Set confirm=true to anonymize account data'
          }, status: :unprocessable_entity
        end

        suffix = SecureRandom.hex(6)

        current_user.transaction do
          current_user.avatar.purge if current_user.respond_to?(:avatar) && current_user.avatar.attached?

          current_user.update!(
            first_name: 'Anonymized',
            last_name: 'User',
            email: "anonymized-#{current_user.id}-#{suffix}@example.invalid",
            phone: nil,
            is_active: false,
            password: SecureRandom.hex(24),
            password_confirmation: nil
          )
        end

        render json: {
          success: true,
          message: 'Account anonymized successfully'
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          error: "Anonymization failed: #{e.message}"
        }, status: :unprocessable_entity
      end
    end
  end
end

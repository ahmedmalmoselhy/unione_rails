module Api
  module Admin
    class DashboardController < BaseController
      def index
        authorize :dashboard, :index?

        render json: {
          success: true,
          data: {
            overview: overview_stats,
            recent_activity: recent_activity,
            enrollment_trends: enrollment_trends,
            academic_performance: academic_performance
          }
        }, status: :ok
      end

      private

      def overview_stats
        {
          total_students: ::Student.count,
          active_students: ::Student.where(enrollment_status: :active).count,
          total_professors: ::Professor.count,
          total_courses: ::Course.where(is_active: true).count,
          total_sections: ::Section.count,
          active_sections: ::Section.joins(:academic_term).where(academic_terms: { is_active: true }).count,
          total_enrollments: ::Enrollment.where(status: :active).count,
          total_faculties: ::Faculty.count,
          total_departments: ::Department.count,
          active_terms: ::AcademicTerm.where(is_active: true).count
        }
      end

      def recent_activity
        {
          recent_enrollments: ::Enrollment.includes(student: :user, section: :course)
                                        .order(created_at: :desc)
                                        .limit(10)
                                        .map { |e| enrollment_summary(e) },
          recent_grades: ::Grade.includes(enrollment: [student: :user, section: :course])
                             .order(created_at: :desc)
                             .limit(10)
                             .map { |g| grade_summary(g) },
          recent_users: ::User.order(created_at: :desc)
                           .limit(10)
                           .map { |u| user_summary(u) }
        }
      end

      def enrollment_trends
        active_term = ::AcademicTerm.find_by(is_active: true)
        return {} unless active_term

        {
          term: active_term.name,
          enrollments_by_status: ::Enrollment.where(academic_term_id: active_term.id)
                                          .group(:status)
                                          .count,
          capacity_utilization: ::Section.where(academic_term_id: active_term.id).map do |section|
            {
              section_id: section.id,
              course_code: section.course.code,
              capacity: section.capacity,
              enrolled: section.enrollments.active.count,
              utilization_percent: (section.enrollments.active.count / section.capacity.to_f * 100).round(2)
            }
          end
        }
      end

      def academic_performance
        {
          average_gpa: ::Student.where.not(gpa: nil).average('gpa')&.to_f&.round(2),
          gpa_distribution: {
            excellent: ::Student.where('gpa >= 3.7').count,
            good: ::Student.where('gpa >= 3.0 AND gpa < 3.7').count,
            probation: ::Student.where('gpa >= 2.0 AND gpa < 3.0').count,
            suspension: ::Student.where('gpa < 2.0').count
          },
          attendance_rate: calculate_attendance_rate
        }
      end

      def enrollment_summary(enrollment)
        {
          id: enrollment.id,
          student: enrollment.student.user.full_name,
          course: enrollment.section.course.code,
          status: enrollment.status,
          created_at: enrollment.created_at
        }
      end

      def grade_summary(grade)
        {
          id: grade.id,
          student: grade.enrollment.student.user.full_name,
          course: grade.enrollment.section.course.code,
          letter_grade: grade.letter_grade,
          points: grade.points,
          created_at: grade.created_at
        }
      end

      def user_summary(user)
        {
          id: user.id,
          name: user.full_name,
          email: user.email,
          roles: user.roles.pluck(:slug),
          created_at: user.created_at
        }
      end

      def calculate_attendance_rate
        total_records = ::AttendanceRecord.count
        return 0.0 if total_records.zero?

        present_count = ::AttendanceRecord.where(status: [:present, :late]).count
        (present_count.to_f / total_records * 100).round(2)
      end
    end
  end
end

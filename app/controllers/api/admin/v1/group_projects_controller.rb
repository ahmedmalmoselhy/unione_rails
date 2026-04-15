module Api
  module Admin
    module V1
      class GroupProjectsController < Api::V1::BaseController
        before_action :set_section
        before_action :set_group_project, only: [:show, :update, :destroy]

        def index
          authorize ::GroupProject

          projects = @section.group_projects
                             .includes(:group_project_members, :created_by_user)
                             .order(created_at: :desc)

          render json: {
            success: true,
            data: {
              group_projects: projects.map { |p| project_json(p) }
            }
          }, status: :ok
        end

        def show
          authorize @group_project

          render json: {
            success: true,
            data: {
              group_project: project_json(@group_project, include_members: true)
            }
          }, status: :ok
        end

        def create
          @group_project = @section.group_projects.new(group_project_params)
          @group_project.created_by_user = current_user
          authorize @group_project

          if @group_project.save
            render json: {
              success: true,
              message: 'Group project created successfully',
              data: {
                group_project: project_json(@group_project)
              }
            }, status: :created
          else
            render json: {
              success: false,
              errors: @group_project.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        def update
          authorize @group_project

          if @group_project.members_count > @group_project.max_members && group_project_params[:max_members].present?
            return render json: {
              success: false,
              error: "Cannot set max_members below current member count (#{@group_project.members_count})"
            }, status: :unprocessable_entity
          end

          if @group_project.update(group_project_params)
            render json: {
              success: true,
              data: {
                group_project: project_json(@group_project)
              }
            }, status: :ok
          else
            render json: {
              success: false,
              errors: @group_project.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        def destroy
          authorize @group_project

          @group_project.destroy

          render json: {
            success: true,
            message: 'Group project deleted'
          }, status: :ok
        end

        # Member management
        def add_member
          authorize ::GroupProject

          @group_project = @section.group_projects.find(params[:id])
          student = ::Student.find(params[:student_id])

          # Verify student is enrolled in the section
          unless @section.enrollments.exists?(student: student, status: :active)
            return render json: {
              success: false,
              error: 'Student is not enrolled in this section'
            }, status: :unprocessable_entity
          end

          if @group_project.full?
            return render json: {
              success: false,
              error: 'Group project is at maximum capacity'
            }, status: :unprocessable_entity
          end

          if @group_project.students.include?(student)
            return render json: {
              success: false,
              error: 'Student is already in this group project'
            }, status: :unprocessable_entity
          end

          if @group_project.add_student(student)
            render json: {
              success: true,
              message: 'Student added to group project',
              data: {
                member: member_json(@group_project.group_project_members.find_by(student: student))
              }
            }, status: :created
          else
            render json: {
              success: false,
              errors: ['Failed to add student to group project']
            }, status: :unprocessable_entity
          end
        end

        def remove_member
          authorize ::GroupProject

          @group_project = @section.group_projects.find(params[:id])
          member = @group_project.group_project_members.find(params[:member_id])
          member.destroy

          render json: {
            success: true,
            message: 'Student removed from group project'
          }, status: :ok
        end

        private

        def set_section
          @section = ::Section.find(params[:section_id])
        end

        def set_group_project
          @group_project = @section.group_projects.find(params[:id])
        end

        def project_json(project, include_members: false)
          json = {
            id: project.id,
            section_id: project.section_id,
            title: project.title,
            description: project.description,
            due_at: project.due_at,
            max_members: project.max_members,
            is_active: project.is_active,
            current_members_count: project.current_members_count,
            created_by: project.created_by_user&.full_name,
            created_at: project.created_at
          }

          if include_members
            json[:members] = project.group_project_members.includes(student: :user).map { |m| member_json(m) }
          end

          json
        end

        def member_json(member)
          {
            id: member.id,
            student: {
              id: member.student.id,
              student_number: member.student.student_number,
              name: member.student.user.full_name,
              email: member.student.user.email
            },
            joined_at: member.joined_at
          }
        end

        def group_project_params
          params.permit(:title, :description, :due_at, :max_members, :is_active)
        end
      end
    end
  end
end

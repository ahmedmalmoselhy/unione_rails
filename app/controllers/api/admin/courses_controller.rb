module Api
  module Admin
    class CoursesController < BaseController
      before_action :set_course, only: [:show, :update, :destroy]

      def index
        @courses = Course.order(:code).page(params[:page]).per(params[:per_page] || 20)
        
        if params[:level]
          @courses = @courses.where(level: params[:level])
        end
        
        if params[:is_elective]
          @courses = @courses.where(is_elective: params[:is_elective])
        end
        
        authorize Course

        render json: @courses, status: :ok
      end

      def show
        authorize @course

        render json: @course, include: ['departments', 'prerequisites'], status: :ok
      end

      def create
        @course = Course.new(course_params)
        authorize @course

        if @course.save
          render json: @course, status: :created
        else
          render json: { errors: @course.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        authorize @course

        if @course.update(course_params)
          render json: @course, status: :ok
        else
          render json: { errors: @course.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @course

        @course.destroy
        render json: { message: 'Course deleted' }, status: :ok
      end

      private

      def set_course
        @course = Course.find(params[:id])
      end

      def course_params
        params.require(:course).permit(
          :code, :name, :name_ar, :description, :credit_hours, :lecture_hours,
          :lab_hours, :level, :is_elective, :is_active
        )
      end
    end
  end
end

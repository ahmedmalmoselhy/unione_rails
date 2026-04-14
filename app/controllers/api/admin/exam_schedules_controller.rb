module Api
  module Admin
    class ExamSchedulesController < Api::BaseController
      before_action :set_section

      def show
        @schedule = ExamScheduleService.new.get_exam_schedule(@section)
        
        if @schedule.blank?
          render json: { error: 'No exam schedule found for this section' }, status: :not_found
        else
          render json: @schedule
        end
      end

      def create
        exam_data = {
          date: params[:date],
          start_time: params[:start_time],
          end_time: params[:end_time],
          location: params[:location],
          type: params[:type] || 'final',
          notes: params[:notes]
        }

        schedule = ExamScheduleService.new.create_exam_schedule(@section, exam_data)
        
        render json: schedule, status: :created
      end

      def update
        exam_data = {
          date: params[:date],
          start_time: params[:start_time],
          end_time: params[:end_time],
          location: params[:location],
          type: params[:type],
          notes: params[:notes]
        }.compact

        @section.update(exam_schedule: @section.exam_schedule.merge(exam_data))
        
        render json: @section.exam_schedule
      end

      def publish
        result = ExamScheduleService.new.publish_exam_schedule(@section)
        
        if result
          render json: { message: 'Exam schedule published successfully', schedule: @section.exam_schedule }
        else
          render json: { error: 'No exam schedule to publish' }, status: :unprocessable_entity
        end
      end

      private

      def set_section
        @section = Section.find(params[:section_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Section not found' }, status: :not_found
      end
    end
  end
end

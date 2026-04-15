module Api
  module Admin
    class UniversityLogosController < BaseController
      MAX_FILE_SIZE = 5.megabytes

      before_action :set_university

      def show
        unless @university.logo.attached?
          return render json: { success: false, error: 'University logo not found' }, status: :not_found
        end

        render json: {
          success: true,
          data: {
            logo: attachment_payload(@university.logo)
          }
        }, status: :ok
      end

      def create
        authorize @university, :update?

        unless params[:file].present?
          return render json: { success: false, error: 'No file provided' }, status: :unprocessable_entity
        end

        unless valid_image_upload?(params[:file])
          return render json: {
            success: false,
            error: 'File must be an image and 5MB or less'
          }, status: :unprocessable_entity
        end

        @university.logo.purge if @university.logo.attached?
        @university.logo.attach(params[:file])

        render json: {
          success: true,
          message: 'University logo uploaded successfully',
          data: {
            logo: attachment_payload(@university.logo)
          }
        }, status: :ok
      end

      def destroy
        authorize @university, :update?

        unless @university.logo.attached?
          return render json: { success: false, error: 'University logo not found' }, status: :not_found
        end

        @university.logo.purge

        render json: {
          success: true,
          message: 'University logo deleted successfully'
        }, status: :ok
      end

      private

      def set_university
        @university = University.find(params[:university_id])
      end

      def valid_image_upload?(file)
        file.content_type.to_s.start_with?('image/') && file.size.to_i <= MAX_FILE_SIZE
      end

      def attachment_payload(attachment)
        blob = attachment.blob

        {
          id: blob.id,
          filename: blob.filename.to_s,
          content_type: blob.content_type,
          byte_size: blob.byte_size,
          created_at: blob.created_at
        }
      end
    end
  end
end

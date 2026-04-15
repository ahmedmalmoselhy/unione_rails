module Api
  module Users
    class AvatarController < Api::BaseController
      MAX_FILE_SIZE = 5.megabytes

      def show
        unless current_user.avatar.attached?
          return render json: { success: false, error: 'Avatar not found' }, status: :not_found
        end

        render json: {
          success: true,
          data: {
            avatar: attachment_payload(current_user.avatar)
          }
        }, status: :ok
      end

      def create
        unless params[:file].present?
          return render json: { success: false, error: 'No file provided' }, status: :unprocessable_entity
        end

        unless valid_image_upload?(params[:file])
          return render json: {
            success: false,
            error: 'File must be an image and 5MB or less'
          }, status: :unprocessable_entity
        end

        current_user.avatar.purge if current_user.avatar.attached?
        current_user.avatar.attach(params[:file])

        render json: {
          success: true,
          message: 'Avatar uploaded successfully',
          data: {
            avatar: attachment_payload(current_user.avatar)
          }
        }, status: :ok
      end

      def destroy
        unless current_user.avatar.attached?
          return render json: { success: false, error: 'Avatar not found' }, status: :not_found
        end

        current_user.avatar.purge

        render json: {
          success: true,
          message: 'Avatar deleted successfully'
        }, status: :ok
      end

      private

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

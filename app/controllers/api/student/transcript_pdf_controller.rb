module Api
  module Student
    class TranscriptPdfController < BaseController
      def show
        @student = current_user.student
        
        unless @student
          return render json: {
            success: false,
            error: 'User does not have a student profile'
          }, status: :forbidden
        end

        authorize @student, :transcript?

        transcript = TranscriptGenerator.new(@student).generate
        pdf = TranscriptPdf.new(@student, transcript).generate

        send_data pdf,
                  filename: "transcript_#{@student.student_number}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end
end

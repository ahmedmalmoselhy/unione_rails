module Api
  class LocaleController < ActionController::API
    def show
      render json: {
        success: true,
        data: {
          locale: I18n.locale.to_s,
          available_locales: I18n.available_locales.map(&:to_s)
        }
      }, status: :ok
    end

    def update
      locale = params[:locale].to_s

      unless I18n.available_locales.map(&:to_s).include?(locale)
        return render json: {
          success: false,
          error: "Unsupported locale: #{locale}"
        }, status: :unprocessable_entity
      end

      I18n.locale = locale
      response.set_header('Content-Language', locale)

      render json: {
        success: true,
        message: 'Locale updated for this request',
        data: {
          locale: locale,
          available_locales: I18n.available_locales.map(&:to_s)
        }
      }, status: :ok
    end
  end
end

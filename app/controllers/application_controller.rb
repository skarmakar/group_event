class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def respond_with_errors(object)
    render json: {errors: ErrorSerializer.serialize(object)}, status: 422
  end

  def not_found
    render json: { 
      errors: [
        {
          status: 404,
          source: controller_name,
          detail: I18n.t('controller.resource_not_found')
        }
      ]
    }, status: 404
  end
end

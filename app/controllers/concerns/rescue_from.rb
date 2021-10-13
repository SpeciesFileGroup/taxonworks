# Some say rescue from is a very bad pattern in Rails.  Before extending content here review those arguments.
module RescueFrom
  extend ActiveSupport::Concern

  included do
    rescue_from 'ActiveRecord::RecordNotFound', with: :record_not_found

    rescue_from 'ActionController::ParameterMissing' do |exception|
      raise unless request.format == :json
      render json: { error: exception }, status: 400
    end

    rescue_from 'ActiveRecord::ConnectionTimeoutError' do |exception|
      raise unless request.format == :json
      render json: { error: exception }, status: 503
    end

    private

    def record_not_found
      respond_to do |format|
        format.html { render plain: '404 Not Found', status: 404 }
        format.json { render json: {success: false}, status: 404 }
      end
    end

  end
end

# Some say rescue from is a very bad pattern in Rails.  Before extending content here review those arguments.
# TODO:
#   - as a more specific fix, inspect path for `/api` for those calls that we only intend to catch there
#   - consider forking to api controllers in the future (Api::RescueFrom)
module RescueFrom
  extend ActiveSupport::Concern

  included do

    rescue_from 'ActionController::BadRequest' do |exception|
      raise unless request.format == :json
      render json: {error: exception}, status: :bad_request
    end

    rescue_from 'ActiveRecord::RecordNotFound', with: :record_not_found

    rescue_from 'TaxonWorks::Error::API' do |exception|
      raise unless request.format == :json
      render json: {error: exception}, status: :bad_request
    end

    rescue_from 'ActionController::ParameterMissing' do |exception|
      raise unless request.format == :json
      render json: { error: exception }, status: :bad_request
    end

    rescue_from 'ActiveRecord::ConnectionTimeoutError' do |exception|
      raise unless request.format == :json
      render json: { error: exception }, status: :service_unavailable
    end

    private

    def record_not_found
      respond_to do |format|
        format.html { render plain: '404 Not Found', status: :not_found }
        format.json { render json: {success: false}, status: :not_found }
      end
    end

  end
end

module RedirectHelper
  extend ActiveSupport::Concern

  # @param object [Object] an ActiveRecord model instance
  # @params args keyword arguments for redirect_to
  def destroy_redirect(object, **args)
    back_location = (request.referer || root_path)

    unless object.persisted?
    begin
      back_params = Rails.application.routes.recognize_path(back_location)
      show_params = { controller: controller_name, action: 'show', id: object.id.to_s }

      # NOTE: url_for resolves to index action if object is not persisted
      back_location = url_for(object) if back_params == show_params
    rescue
    end

    redirect_to(back_location, args)
  end
end

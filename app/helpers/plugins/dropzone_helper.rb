module Plugins::DropzoneHelper

  def dropzone_form(image = nil) 
    if image.blank?
      form_tag( images_path, method: :post, authenticity_token: form_authenticity_token, class: :dropzone, id: 'basic-images') 
    else
      form_tag( image_path(image), method: :patch, authenticity_token: form_authenticity_token, class: :dropzone, id: 'basic-images') 
    end
  end

  def dropzone_depiction_form(object)
    if object.respond_to?(:depictions) && !object.class.name == 'Image'
      form_tag(depictions_path, method: :post, authenticity_token: form_authenticity_token, class: :dropzone, id: 'depiction-images') do
        hidden_field_tag('depiction[depiction_object_type]', object.class.name ).html_safe + hidden_field_tag('depiction[depiction_object_id]', object.id.to_s).html_safe
      end
    end
  end


end

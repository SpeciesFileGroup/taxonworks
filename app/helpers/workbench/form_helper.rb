module Workbench::FormHelper

  def destroy_related_link(f, text: 'x')
    content_tag(:span, text, class: 'destroyable', 'data-object-name' => f.object_name) if !f.object.new_record? 
  end

end

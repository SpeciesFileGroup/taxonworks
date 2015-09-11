# Helpers that generate simple lists, tables etc.
module Workbench::ListHelper

  def similarly_named_records_list(instance)
    model   = instance.class
    name    = instance.name
    records = model.where(['(name LIKE ? OR NAME like ?) AND id != ?', "#{name}%", "%#{name}%", instance]).limit(5)
    content_tag(:span) do
      content_tag(:em, 'Similarly named records: ') +
          content_tag(:span) do
            (records.count == 0 ?
                'none' :
                records.collect { |r| link_to(r.name, r) }.join(', ').html_safe)
          end
    end
  end

  def recent_objects_list(model, recent_objects)
    partial = nil
    base = model.name.tableize  
    if self.respond_to?("#{base}_recent_objects_partial") 
      partial =  "/#{base}/recent_objects_list"
    else
      partial = '/shared/data/project/recent_objects_list'
    end

    render partial: partial , locals: {recent_objects: recent_objects}
  end


  def list_tag(object, method)
    return content_tag(:div, object_tag(object) + "has no method #{method}") unless object.respond_to?(method)
    if object.send(method).any?
      content_tag(:ul) do
        object.send(method).collect{|i|
          content_tag(:li, object_tag(i))
        }.join.html_safe
      end
    else
      content_tag(:span, "No #{method} attached.", class: :warning)
    end
  end

#   elsif model.annotates?
#     render partial: "/#{params[:controller]}/recent_objects_list", locals: {recent_objects: recent_objects}
#   else
#     render partial: , locals: {recent_objects: recent_objects}
#   end
# end



end

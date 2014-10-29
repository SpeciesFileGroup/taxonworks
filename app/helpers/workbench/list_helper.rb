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
end

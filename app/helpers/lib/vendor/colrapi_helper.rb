module Lib::Vendor::ColrapiHelper

  def colrapi_usage_status_tag(name_status)
    case name_status[:provisional_status]
    when :accepted
      tag.span('accepted', class: [:feedback, 'feedback-info', 'feedback-thin'])
    when :undeterminable
      tag.span('undeterminable', class: [:feedback, 'feedback-warning', 'feedback-thin'])
    when :synonym
      tag.span('synonym', class: [:feedback, 'feedback-danger', 'feedback-thin'])
    end
  end

  def colrapi_filter_link(collection_object, name_status)
    if name_status[:provisional_status]
      if collection_object.current_taxon_name
        link_to('Filter', filter_collection_objects_task_url(taxon_name_id: collection_object.current_taxon_name.id), target: :_blank, rel: :noopener)
      end
    end
  end

end

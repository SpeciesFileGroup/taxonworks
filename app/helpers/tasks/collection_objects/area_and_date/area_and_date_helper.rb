module Tasks::CollectionObjects::AreaAndDate::AreaAndDateHelper

  def paging_info
    # <p><%= page_entries_info(@collection_objects) %></p> <%= paginate @collection_objects %>
    if @collection_objects.any?
      page_entries_info(@collection_objects)
    end
  end

  def paging
    if @collection_objects.any?
      paginate(@collection_objects, :remote => true)
    end
  end

  def id_range_select_tag(id_range_element, option_list)
    select_tag(id_range_element, options_for_select(option_list), prompt: 'Select an identifier')
  end

  def get_first_created_at
    colobj = CollectionObject.with_project_id(sessions_current_project_id).first_created
    if colobj.blank?
      '1700/01/01'
    else
      colobj.created_at.to_date.to_s.gsub('-', '/')
    end
  end

  def get_last_created_at
    colobj = CollectionObject.with_project_id(sessions_current_project_id).last_created
    if colobj.blank?
      Date.today.to_s.gsub('-', '/')
    else
      colobj.created_at.to_date.to_s.gsub('-', '/')
    end
  end

end

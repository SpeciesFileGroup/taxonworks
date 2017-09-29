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

end

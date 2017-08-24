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
end

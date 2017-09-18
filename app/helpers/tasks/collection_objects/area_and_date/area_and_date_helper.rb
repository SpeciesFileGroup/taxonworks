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

  def id_range_select_tag(id_range_element)
    pile = CollectionObject.with_identifier_type_and_namespace('Identifier::Local::CatalogNumber')
             .collect {|sp| sp.identifiers}
             .flatten
             .map(&:identifier)
    select_tag(id_range_element, options_for_select(pile), prompt: 'Select an identifier')
  end

end

module Tasks::Otus::AreaAndNomen::AreaAndNomenHelper

  def otu_paging_info
    # <p><%= page_entries_info(@otus) %></p> <%= paginate @otus %>
    if @otus.any?
      page_entries_info(@otus)
    end
  end

  def otu_paging
    if @otus.any?
      paginate(@otus, :remote => true)
    end
  end

  # def id_range_select_tag(id_range_element, option_list)
  #   select_tag(id_range_element, options_for_select(option_list), prompt: 'Select an identifier')
  # end
  #
  # def get_first_created_at
  #   colobj = CollectionObject.with_project_id(sessions_current_project_id).first_created
  #   if colobj.blank?
  #     Utilities::Dates::EARLIEST_DATE # 1700/01/01
  #   else
  #     colobj.created_at.to_date.strftime('%Y/%m/%d')
  #   end
  # end
  #
  # def get_last_created_at
  #   colobj = CollectionObject.with_project_id(sessions_current_project_id).last_created
  #   if colobj.blank?
  #     Date.today.strftime('%Y/%m/%d')
  #   else
  #     colobj.created_at.to_date.strftime('%Y/%m/%d')
  #   end
  # end

end

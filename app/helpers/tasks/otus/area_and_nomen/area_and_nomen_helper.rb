module Tasks::Otus::AreaAndNomen::AreaAndNomenHelper

 # <p><%= page_entries_info(@otus) %></p> <%= paginate @otus %>
  def otu_paging_info
    if @otus.any?
      page_entries_info(@otus)
    else
      "Displaying no otus"
    end
  end

  def otu_paging
    if @otus.any?
      paginate(@otus, :remote => true)
    end
  end

end

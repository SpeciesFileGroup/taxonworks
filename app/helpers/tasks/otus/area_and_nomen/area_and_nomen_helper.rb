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

  def otu_taxon_name_rank_select_tag(taxon_name: TaxonName.new, options: {})
    select_tag(:rank_class, options_for_select(RANKS_SELECT_OPTIONS, selected: taxon_name.rank_string, options: options))
  end

end

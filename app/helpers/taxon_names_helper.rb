module TaxonNamesHelper

  def self.taxon_name_tag(taxon_name)
    return nil if taxon_name.nil?
    taxon_name.cached_name || taxon_name.name # TODO: fix cached name generation
  end

  def taxon_name_tag(taxon_name)
    TaxonNamesHelper.taxon_name_tag(taxon_name)
  end

  def taxon_name_link(taxon_name)
    return nil if taxon_name.nil?
    link_to(taxon_name_tag(taxon_name).html_safe, taxon_name)
  end

  def taxon_names_search_form
    render '/taxon_names/quick_search_form'
  end

  def taxon_name_for_select(taxon_name)
    taxon_name.name
  end

  # @taxon_name.parent.andand.display_name(:type => :for_select_list)
  def parent_taxon_name_for_select(taxon_name)
    taxon_name.parent ? taxon_name_for_select(taxon_name.parent) : nil
  end

  # TODO: Scope to code
  def taxon_name_rank_select_tag(taxon_name = TaxonName.new, code = nil)
    select(:taxon_name, :rank_class, options_for_select(ICZN_LOOKUP.collect { |k, v| ["#{k} (ICZN)", v] } + ICN_LOOKUP.collect { |k, v| ["#{k} (ICN)", v] }), default: taxon_name.rank_class)
  end

end

module TaxonNamesHelper
 
  def taxon_name_for_select(taxon_name)
    taxon_name.name  
  end

  # @taxon_name.parent.andand.display_name(:type => :for_select_list)
  def parent_taxon_name_for_select(taxon_name)
    taxon_name.parent ? taxon_name_for_select(taxon_name.parent) : nil
  end

  def self.display_taxon_name(taxon_name)
    taxon_name.name 
  end

  def display_taxon_name(taxon_name)
    TaxonNamesHelper.display_taxon_Name(taxon_name)
  end

  # TODO: Scope to code
  def taxon_name_rank_select_tag(taxon_name = TaxonName.new, code = nil)
    select(:taxon_name, :rank_class, options_for_select( ICZN_LOOKUP.collect{|k,v| ["#{k} (ICZN)", v]} + ICN_LOOKUP.collect{|k,v| ["#{k} (ICN)", v]}), default: taxon_name.rank_class  )
  end

end

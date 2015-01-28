module CombinationsHelper

  def new_combination_for_protonym_link(taxon_name)
    link_to('New combination', new_combination_path(taxon_name_id: taxon_name)) if GENUS_AND_SPECIES_RANK_NAMES.include?(taxon_name.rank_string)
  end

end

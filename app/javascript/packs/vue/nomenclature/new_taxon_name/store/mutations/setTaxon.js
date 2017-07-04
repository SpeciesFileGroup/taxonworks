module.exports = function(state, taxon) {
	state.taxon_name.id = taxon.id;
    state.taxon_name.parent_id = taxon.parent_id;
    state.taxon_name.name = taxon.name;
    state.taxon_name.rank_class = taxon.rank_class;
    state.taxon_name.year_of_publication = taxon.year_of_publication;
    state.taxon_name.verbatim_author = taxon.verbatim_author;
    state.taxon_name.feminine_name = taxon.feminine_name;
    state.taxon_name.masculine_name = taxon.masculine_name;
    state.taxon_name.neuter_name = taxon.neuter_name;
};
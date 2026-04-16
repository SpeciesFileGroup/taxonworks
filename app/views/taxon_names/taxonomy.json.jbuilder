json.merge! taxonomic_tree(@taxon_name, params[:ancestors] != 'false', params[:count] == 'true')

export default function(state) {
  state.settings.locked = {
    biocuration: true,
    identifier: true,
    collecting_event: true,
    collection_object: {
      buffered_determinations: true,
      buffered_collecting_event: true,
      buffered_other_labels: true,
      repository_id: true,
      preparation_type_id: true
    },
    taxon_determination: {
      otu_id: true,
      year_made: true,
      month_made: true,
      day_made: true,
      roles_attributes: true,    
      dates: true      
    }
  }
}
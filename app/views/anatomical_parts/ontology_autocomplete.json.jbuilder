json.array! @parts_list.map { |part|
  part.merge(ontology_label: anatomical_part_ontology_label(part))
}
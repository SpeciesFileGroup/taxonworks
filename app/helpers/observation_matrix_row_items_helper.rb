module ObservationMatrixRowItemsHelper

  # !! when dynamic rows are extended this will have to reflect other types than tags 
  def observation_matrix_row_item_tag(observation_matrix_row_item)
    return nil if observation_matrix_row_item.nil?
    if observation_matrix_row_item.is_dynamic?
      case observation_matrix_row_item.type
      when 'ObservationMatrixRowItem::Dynamic::Tag'
        (controlled_vocabulary_term_tag(observation_matrix_row_item.observation_object) + ' (tag keyword)').html_safe
      when 'ObservationMatrixRowItem::Dynamic::TaxonName'
        (taxon_name_tag(observation_matrix_row_item.observation_object) + ' (taxon name)').html_safe
      else
        'bad type (Admin: see row items helper)'
      end
    else
      [
        object_tag(observation_matrix_row_item.matrix_row_item_object),
        "(single #{observation_matrix_row_item.matrix_row_item_object.class})"
      ].compact.join(' ').html_safe
    end 
  end

  def observation_matrix_row_item_link(observation_matrix_row_item)
    return nil if observation_matrix_row_item.nil?
    link_to(observation_matrix_row_item_tag(observation_matrix_row_item).html_safe, observation_matrix_row_item.metamorphosize)
  end

end

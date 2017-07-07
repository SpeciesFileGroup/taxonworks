module SequencesHelper
  def sequence_tag(sequence)
    return nil if sequence.nil?
    sequence.sequence
  end

  def sequence_autocomplete_selected_tag(sequence)
    sequence_tag(sequence)
  end
  
  def sequences_search_form
    render('/sequences/quick_search_form')
  end

  def sequence_link(sequence)
    return nil if sequence.nil?
    link_to(sequence_tag(sequence).html_safe, sequence)
  end
end

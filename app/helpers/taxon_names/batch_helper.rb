module TaxonNames::BatchHelper

  def nomen_row_object_preview(taxon_name_objects)
    begin
      taxon_name_objects.each_with_index.collect{|n, i| "#{i + 1}: " +  n.get_full_name.to_s }.join('<br>').html_safe 
    rescue TaxonWorks::Error => e
      tag.span "ERROR. Likely recursion issue (bad parent, or row order): #{e}", class: [:feedback, 'feedback-thin', 'feedback-failure']
    end
  end


end

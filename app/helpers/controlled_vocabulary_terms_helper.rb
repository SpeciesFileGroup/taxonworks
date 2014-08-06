module ControlledVocabularyTermsHelper

  def self.controlled_vocabulary_term_tag(controlled_vocabulary_term)
    return nil if controlled_vocabulary_term.nil?
    controlled_vocabulary_term.name
  end

  def controlled_vocabulary_term_tag(controlled_vocabulary_term)
    ControlledVocabularyTermsHelper.controlled_vocabulary_term_tag(controlled_vocabulary_term)
  end

  def controlled_vocabulary_term_link(controlled_vocabulary_term)
    return nil if controlled_vocabulary_term.nil?
    link_to(controlled_vocabulary_term_tag(controlled_vocabulary_term).html_safe, controlled_vocabulary_term)
  end

  def controlled_vocabulary_term_type_select_options
    %w[Keyword Topic Predicate BiologicalProperty BiocurationGroup BiocurationClass]
  end

  def term_and_definition_tag(controlled_vocabulary_term)
    content_tag(:span, controlled_vocabulary_term) + ': ' + content_tag(:span, controlled_vocabulary_term.definition)
  end


end

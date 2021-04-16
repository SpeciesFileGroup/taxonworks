module Utilities::Italicize

  # Used to italicize strings, whitespace (presently) matters
  # Ultimately turn into Tokens to better handle whitespace
  COMBINATION_INJECTIONS = [ 
    ' (',
    ') ', # no trailing whitespace as it could be terminating in case of subgenus?
    ' [sic]',
    ' var.',
    ' subvar.',
    ' f.',
    ' subf.',
    ' sect.', # not covered in original combination
    ' ser.',  # not covered in original combination 
    'GENUS NOT SPECIFIED',
    'SPECIES NOT SPECIFIED',
    '[',
    ']',
    '† ', # fossil dagger
    ' ×',  # hybrid ×
    # 'Candidatus' ? 
  ].freeze

  COMBINATION_INJECTION_REGEX = COMBINATION_INJECTIONS.collect{|a| Regexp.escape(a) }.join('|').freeze

  # @return [String, nil]
  def self.taxon_name(string)
    # Don't use .blank?, anticipate moving out of Rails
    return nil if string.nil? || string == ''

    # May need to revert to this 1:1 form if we find that an individual COMBINATION_INJECTS element are found > 1 per name 
    # TaxonName::COMBINATION_INJECTIONS.collect{|a| Regexp.escape(a)  }.each do |r|
    #   string.gsub!(/(#{r})/, '</i>\1<i>')
    # end
    
    string.gsub!(/(#{COMBINATION_INJECTION_REGEX})/, '</i>\1<i>')
    string = "<i>#{string}</i>"
    string.gsub!('<i> ', ' <i>')
    string.gsub!(')</i>', '</i>)')
    string.gsub!('<i></i>', '')
    string
  end

end

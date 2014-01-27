module Utilities::Dates

  ROMAN_MONTHS = %i{i ii iii iv v vi vii viii ix x xi xii}

  # TODO: Write unit tests
  # Concept from from http://www.rdoc.info/github/inukshuk/bibtex-ruby/master/BibTeX/Entry
  # Converts integers, month names, or roman numerals, regardless of class to three letter symbols.
  #   SHORT_MONTH_FILTER[1]         # => :jan
  #   SHORT_MONTH_FILTER['JANUARY'] # => :jan
  #   SHORT_MONTH_FILTER['i']       # => :jan
  #   SHORT_MONTH_FILTER['I']       # => :jan
  #   SHORT_MONTH_FILTER['foo']     # => 'foo':
  SHORT_MONTH_FILTER = 
    Hash.new do |h,k|
      v = k.to_s.strip
      if v =~ /^(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)/i
        h[k] = v[0,3].downcase.to_sym
      else
        i = nil
        if v =~ /^\d\d?$/
          i = v.to_i
        elsif ROMAN_MONTHS.include?(v.downcase.to_sym)
          i = ROMAN_MONTHS.index(v.downcase.to_sym) + 1
        end 
        if !i.nil? && i > 0 && i < 13
          h[k] = DateTime.new(1, i, 1).strftime("%b").downcase.to_sym
        else # return the value passed if it doesn't match
          k
        end
      end
    end
end

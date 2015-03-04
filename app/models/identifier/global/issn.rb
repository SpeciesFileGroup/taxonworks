class Identifier::Global::Issn < Identifier::Global
=begin
  From http://www.issn.org/understanding-the-issn/what-is-an-issn/ on 1/31/2014
    An ISSN takes the following form:
      - the acronym ISSN is shown in capitals,
      - followed by a space,
      - followed by two groups of four digits, separated by a hyphen.

    The number must always be preceded by the ISSN acronym.

  From Wikipedia  http://en.wikipedia.org/wiki/International_Standard_Serial_Number on 1/31/2014
    The format of the ISSN is an eight digit number, divided by a hyphen into two four-digit numbers.
    The last digit, which may be 0–9 or an X, is a check digit.
=end
  # validates :identifier, :format => {:with => /\A\d\d\d\d-\d\d\d[\dxX]\z/, :message => 'Invalid ISSN.'}
  validate :using_issn_class

  # Examples from issn.org: ISSN 0317-8471, ISSN 1050-124X

  # TODO: the validator for this identifier has been perverted so as to *NOT* require the preamble 'ISSN ', even though the ISSN spec is quite specific about its being there, because the Bibtex gem does not return it with the ISSN vslue as it should.
  def using_issn_class
    validate_preamble = false
    retval            = true
    unless identifier.nil?
      issn = identifier.upcase

      # 'ISSN 1234-567X'
      /^(?<preamble>ISSN ){0,1}(?<part_1>\d{4})-(?<part_2>\d{3})(?<last>.)$/ =~ issn

      if part_1.nil? or part_2.nil? or last.nil? or (preamble.nil? and validate_preamble)
        errors.add(:identifier, "'#{identifier}' is an improperly formed ISSN.")
        return false
      end

      data = part_1 + part_2
      if last == 'X'
        sum = 10
      else
        sum = last.to_i
      end
      index = 8

      data.each_char { |c|
        sum   += c.to_i * index
        index -= 1
      }
      sum = (sum % 11)

      if sum != 0
        errors.add(:identifier, "'#{identifier}' has bad check digit.")
        return false
      end
    end
    retval
  end
end

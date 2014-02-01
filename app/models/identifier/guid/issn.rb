class Identifier::Guid::Issn < Identifier::Guid
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
  validates :identifier, :format => {:with => /\A\d\d\d\d-\d\d\d[\dxX]\z/, :message => 'Invalid ISSN.'}
  end

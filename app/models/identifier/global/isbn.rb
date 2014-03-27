class Identifier::Global::Isbn < Identifier::Global
  # Officially all ISBNs are now 13 digits - however anything published prior to 2007 may have a 10 digit format that
  # requires special processing (see isbn.org) to convert a 10 digit ISBN to a 13 digit ISBN. For our purposes we will
  # allow either a 10 digit or a 13 digit ISBN. - 1/31/2014
  #
=begin
  From the International ISBN Agency (http://isbn-international.org/faqs) on 1/31/2014 :
  Each ISBN consists of 5 parts with each section being separated by spaces or hyphens.
  Three of the five elements may be of varying length:
    Prefix element – currently this can only be either 978 or 979 (it is always 3 digits).
    Registration group element – this identifies the particular country, geographical region, or language area
      participating in the ISBN system. This element may be between 1 and 5 digits in length.
    Registrant element - this identifies the particular publisher or imprint. This may be up to 7 digits in length.
    Publication element – this identifies the particular edition and format of a specific title. This may be up to 6
      digits in length
    Check digit – this is always the final single digit that mathematically validates the rest of the number.
      It is calculated using a Modulus 10 system with alternate weights of 1 and 3.
=end

  # all of this means that it is difficult to validate an ISBN.

  # validations contains at least 10 digit & only digits, dashes, or spaces
 validates :identifier, :format => {:with => /\A[\d\s-]*\z/, :message => 'Only digits, spaces and dashes allowed.'}
 # doesn't allow blank identifier, because can only create an object if it has an identifier.
  def ten_or_thirteen_digits?
    #TODO beth will talk to Jim when she gets back from vacation on how to correctly extract only the digits from the string.
    #count = 0
    #carray = self.chars
    #carray.each do |c|
    #  if c.is_digit?
    #end

  end
end

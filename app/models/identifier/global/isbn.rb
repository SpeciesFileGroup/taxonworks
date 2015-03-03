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
  # validates :identifier, :format => {:with => /\A[\d\s-]*\z/, :message => 'Only digits, spaces and dashes allowed.'}
  # doesn't allow blank identifier, because can only create an object if it has an identifier.

  validate :using_isbn_class

  def using_isbn_class
    retval = true
    unless identifier.nil?
      isbn = identifier.upcase
      # 'ISBN-13: 978-0-596-52068-7'
      isbn.gsub!('ISBN-10', '')
      type = $&
      isbn.gsub!('ISBN-13', '')
      type ||= $&
      type.gsub!('ISBN-', '') unless type.nil?
      isbn.gsub!('ISBN', '')
      # ': 978-0-596-52068-7'
      isbn.gsub!(':', '')
      # ' 978-0-596-52068-7'
      isbn.strip!
      # '978-0-596-52068-7' or '978 0 596 52068 7'
      # if there are spaces or hyphens, check to see that they are in the right places
      /^(\d{3}[ -]{0,1}){0,1}\d{1,5}[ -]{0,1}\d{1,5}[ -]{0,1}\d{1,5}[ -]{0,1}(?<last>.)$/ =~ isbn

      isbn.gsub!(' ', '')
      isbn.gsub!('-', '')
      # if there are *any* non-digits left, it is improperly formed
      # NB! 'X' is a valid digit in this case
      /[^\dX]/ =~ isbn
      unless $&.nil?
        errors.add(:identifier, "'#{identifier}' is an improperly formed ISBN.")
        return false
      end
      # the final (checksum) digit has alreaqdy been identified, so we need 12 or 9 here
      /^(?<isbn_13>\d{12})\d$|^(?<isbn_10>\d{9}).$/ =~ isbn

      if ($&.nil?) or
        (isbn_10.nil? and isbn_13.nil?) or
        ((isbn_10.nil? and type == '10') or (isbn_13.nil? and type == '13'))
        errors.add(:identifier, "'#{identifier}' has the wrong number of digits.")
        return false
      end

      data  = isbn.slice(0, isbn.size - 1)
      sum   = 0
      index = 0
      # last  = 10 if last == 'X'

      if data.size == 9
        data.reverse!
        data.each_char { |c|
          factor = (index + 2)
          sum    += factor * c.to_i
          index  += 1
        }

        check_byte = 11 - (sum % 11)
        if check_byte == 10
          check_byte = 'X'
        else
          if check_byte == 11
            check_byte = 0
          end
        end
      else
        data.each_char { |c|
          factor = (((index % 2) * 2) + 1)
          sum    += factor * c.to_i
          index  += 1
        }
        check_byte = 10 - (sum % 10)
        if check_byte == 10
          check_byte = 0;
        end
      end

      # check_byte and/or last might be an 'X'
      if check_byte.to_s != last
        errors.add(:identifier, "'#{identifier}' has bad check digit.")
        return false
      end

    end
    retval
  end

  def ten_or_thirteen_digits?
    #TODO beth will talk to Jim when she gets back from vacation on how to correctly extract only the digits from the string.
    #count = 0
    #carray = self.chars
    #carray.each do |c|
    #  if c.is_digit?
    #end

  end
end

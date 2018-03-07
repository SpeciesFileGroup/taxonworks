# @todo This validation will be needing a lot of additional work, if we start relying on it. See http://www.loc.gov/marc/bibliographic/bd010.html
#
#   LCCN Structure A (1898-2000)
#     Name of Element 	Number of characters 	Character position in field
#     Alphabetic prefix 	        3 	          00-02
#     Year 	                      2 	          03-04
#     Serial number 	            6 	          05-10
#     Supplement number 	        1 	          11
#     Suffix and/or Revision Date variable 	    12-n
#
#   LCCN Structure B (2001- )
#     Name of Element 	Number of characters 	Character position in field
#     Alphabetic prefix   2 	                    00-01
#     Year                4 	                    02-05
#     Serial number 	    6 	                    06-11
#
#   Alphabetic prefix
#     Prefixes are carried in a MARC record as lowercase alphabetic characters and serve to differentiate
#       between different series of LC control numbers. Prefixes are left justified and unused positions
#       contain blanks. If no prefix is present, the prefix portion contains blanks.
#
class Identifier::Global::Lccn < Identifier::Global
  validate :using_iccn_class

  def using_iccn_class
    unless identifier.nil?
      lccn = identifier

      # '200112345', '2010549727', '2003064850', '|a  2003064850', '88156495', '68-004897', '2001-459440'

      #   LCCN Structure A (1898-2000)
      /^(?<preamble_a>.{3}){0,1}(?<year_a>\d{2})-{0,1}(?<serial_a>\d{6})(?<supplement>\d){0,1}(?<suffix>.*)$/i =~ lccn
      #   LCCN Structure B (2001- )
      # this regex should be good for all of the third millennium
      /^(?<preamble_b>.{2}){0,1}(?<year_b>\d{4})-{0,1}(?<serial_b>\d{6})$/i =~ lccn

      century = '19'
      unless year_a.nil?
        serial = serial_a.to_i
        case year_a
          when '98'
            if serial < 3000
              century = '18'
            end
          when '99'
            if serial < 6000
              century = '18'
            end
          when '00'
            if serial >= 8000
              century = '20'
            end
        end
        year = century + year_a
        return
      end

      return unless (year_b.nil? or serial_b.nil?)

      unless year_b.nil?
        year = year_b.to_i
        if (year > Time.now.year) or (year < 2001)
          errors.add(:identifier, "'#{identifier}' is too far in the future, or before 2001.")
          return
        end
      else
        if serial_b.nil?
          errors.add(:identifier, "'#{identifier}' is an improperly formed LCCN.")
          return
        end
      end
    end
  end
end

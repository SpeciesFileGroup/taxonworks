# Orcid definition...
#
class Identifier::Global::Orcid < Identifier::Global
  validate :using_orcid_class

  # 'http://orcid.org/0000-0002-1825-0097'
  def using_orcid_class
    unless identifier.nil?
      orcid = identifier.upcase

      /^(?<preamble>http[s]+:\/\/){0,1}(?<domain>orcid\.org\/){1}(?<part_1>\d{4})-(?<part_2>\d{4})-(?<part_3>\d{4})-(?<part_4>\d{3})(?<last>.)$/i =~ orcid

      if domain.nil? or part_1.nil? or part_2.nil? or part_3.nil? or part_4.nil? or last.nil?
        errors.add(:identifier, "'#{identifier}' is an improperly formed ORCID ID.")
        return
      end

      if last != generate_check_digit(part_1 + part_2 + part_3 + part_4)
        errors.add(:identifier, "'#{identifier}' has bad check digit.")
        return
      end
    end
  end

  def generate_check_digit(base_digits)

    # int total = 0;
    total = 0

    # for (int i = 0; i < baseDigits.length(); i++) {
    base_digits.each_char { |digit|
      #   int digit = Character.getNumericValue(baseDigits.charAt(i));
      # total = (total + digit) * 2;
      # }
      total = (total + digit.to_i) * 2
    }
    # int remainder = total % 11;
    # int result = (12 - remainder) % 11;
    remainder = (total % 11)
    result = (12 - remainder) % 11
    # return result == 10 ? "X" : String.valueOf(result);
    return result == 10 ? 'X' : result.to_s
  end

end

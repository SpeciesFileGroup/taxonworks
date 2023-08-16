# From NCBI-GenBank Flat File Release 220.0 at ftp://ftp.ncbi.nih.gov/genbank/gbrel.txt
# section 3.4.6 ACCESSION format
# There are 2 formats, one format with 1 upper case letter followed by 5 numbers
# and another format with 2 upper case letters followed by 6 numbers
# Format 1: A12345
# Format 2: AB123456
# For use with GenBank sequences

class Identifier::Global::GenBankAccessionCode < Identifier::Global
  validate :valid_gen_bank_accession_code
  validate :sequences_only

  def valid_gen_bank_accession_code
    if identifier.present?
      matched = false

      if /\A[A-Z][A-Z][0-9]{6}\Z/.match(identifier)
        matched = true
      elsif /\A[A-Z][0-9]{5}\Z/.match(identifier)
        matched = true
      end

      if !matched
        errors.add(:identifier, 'invalid format')
      end
    end
  end

  private

  def sequences_only
    errors.add(:identifier_object_type, 'is not a Sequence') if identifier_object_type != 'Sequence'
  end


end

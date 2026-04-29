
# For example  https://api.checklistbank.org/dataset/9802/taxon/1000027.
#
# This has properties that blur into Namespace, we could think of Datasets as Namespaces.
# It is also somewhat hybrid conceptually in that while Global it doesn't have the same rigour as in definition, broadness, etc.
#
# !! Neither of dataset_id and taxon_id need be integers.
class Identifier::Global::Uri::ChecklistBank < Identifier::Global::Uri

  API_ROOT = 'https://api.checklistbank.org'

  VALID_ROOTS = %w{
    https://www.checklistbank.org
    http://api.checklistbank.org
  } + [API_ROOT]

  validate :used_on_taxon_name_or_otu
  validate :path_format

  def api_format
    [API_ROOT, 'dataset', dataset_id , 'taxon', taxon_id ].join('/')
  end

  def dataset_id
    identifier.split('/')[4]
  end

  def taxon_id
    identifier.split('/')[6]
  end

  protected

  def path_format
    errors.add(:identifier) unless identifier.match(/dataset\/.+\/taxon\/.+$/)
  end

  def references_a_known_form
    errors.add(:identifier, "Must start with one of #{VALID_ROOTS.join(', ')}.") if !(identifier =~ /^#{VALID_ROOTS.join('|')}/)
  end

  def used_on_taxon_name_or_otu
     if !%w{TaxonName Otu}.include?(identifier_object_type)
       errors.add(:identifier_object_type, 'ChecklistBank identifiers may only be used on TaxonNames or Otus')
     end
  end

end

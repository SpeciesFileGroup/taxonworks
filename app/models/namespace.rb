# A Namespace is used to define a set of local Identifiers.
# All identifiers within a Namespace must be unique.
# Namespaces are shared across projects.
# In TaxonWorks Identifiers + Namespaces are used for differentiating/disambiguating one datum from another.
# This applies to all local identifiers, not just what most might be familiar with in the
# DwC catalogNumber field.
#
# Namespaces are used to to meet practical needs that also have FAIR consequences:
# * They attempt to provide a degree of provenance as to how the Identifier came to be
# * To differentiate, in practical terms, one identifier from another within the system that merges data
# * To act as a labels (short mneomincs) that allows the data curator to disambiguate what might be otherwise two identical strings
##
# Namespaces are minted in TW on a first come first serve basis.  Their short and
# long names must be unique. When conflicts arise new values must be minted for
# record keeping purposes. In this case a verbatim_short_name can be provided, and this
# value will be presented for reporting/searching purposes.  This is a strong restriction
# that is intended to encourage users to think before they mint a Namespace.
#
# In TaxonWorks Namespaces _do not_ imply ownership of the things they are linked to.  If an identifier has a Namespace
# that includes a reference, in some way, to some Repository, it does not mean that that Repository 'owns' the identified thing.
#
# In natural history collection management many catalog numbers contain an institutional coden as
# part of their catalog number (as physically written).  In TaxonWorks we treat that coden as the basis
# for a Namespace. Note that we also may use the CODEN in a second way, to identify the Repository.
# While the string is duplicate the meaning is not.  One use let's us quickly reference a Repository,
# the second use let's us quickly narrow searches to a specific Identifier linked to our object.
#
# @!attribute institution
# @return [String]
#   The institution (loosely, could be a person) responsible for minting this Namespace.  Roughly, where to look for more information.
#   This is NOT 1:1 with http://rs.tdwg.org/dwc/terms/ownerInstitutionCode, which implies ownership. It is narrower in that
#   it means the institution or individual "owns", or minted this Namespace, that's all.
#
# @!attribute name
# @return [String]
#   The full, descriptive name of the namespace. For example 'Illinois Natural History Collection Insect Collection Identifiers'.
#
# @!attribute short_name
# @return [String]
#   A short, realized version of the name, as seen in the physical label if there is a physical form. For example "INHIC".
#   This may be embedded in http://rs.tdwg.org/dwc/terms/institutionCode.
#   We presently do not differentiate a http://rs.tdwg.org/dwc/terms/collectionCode in
#   identifiers, that data may(?) fall into Repositories.
#
# @!attribute verbatim_short_name
# @return [String]
#   TW enforces uniqueness of short names.  When a short name exists for historical reasons but it has already
#   been included in TW then a new short name must be minted, and a verbatim_short_name used to indicate the
#   physically/and or historically recorded value.
#
# @!attribute delimiter
# @return [String, nil]
#    Defines the character(s) to be placed between the namespace short name and the identifier
#
# @!attribute is_virtual
# @return [Boolean]
#   Defaults to false. If true then the namespace short name is not part of the "physical" identifier.  Required to handle identifiers incoming
# from DwC in some contexts.
#
class Namespace < ApplicationRecord
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::SharedAcrossProjects
  include Shared::HasPapertrail
  include Shared::IsData

  after_update :update_local_idenfifiers

  validates_presence_of :name, :short_name
  validates_uniqueness_of :name, :short_name, case_sensitive: false

  # Autosave should resave all, but it clearly doesn't
  # we also don't want to validte the identifiers on this resave, but rather
  # just trigger the rebuild of identifiers#cache.  Will have to add an after_save here.
  has_many :identifiers, autosave: true, dependent: :restrict_with_error, inverse_of: :namespace

  scope :used_on_klass, -> (klass) { joins(:identifiers).where(identifiers: {identifier_object_type: klass} ) }
  scope :used_recently, -> { joins(:identifiers).includes(:identifiers).where(identifiers: { updated_at: 10.weeks.ago..Time.now } ).order('"identifiers"."created_at" DESC') }
  scope :used_in_project, -> (project_id) { joins(:identifiers).where( identifiers: { project_id: project_id } ) }

  def is_virtual?
    is_virtual
  end

  def self.select_optimized(user_id, project_id, klass)
    h = {
      recent: (
        Namespace.used_on_klass(klass)
        .where(identifiers: {updated_by_id: user_id})
        .used_in_project(project_id)
        .used_recently
        .distinct.limit(6).to_a +
      Namespace.where(created_by_id: user_id, created_at: (3.hours.ago..Time.now)).limit(5)).uniq,
      pinboard: Namespace.pinned_by(user_id).pinned_in_project(project_id).to_a
    }

    h[:quick] = (Namespace.pinned_by(user_id).pinboard_inserted.pinned_in_project(project_id).to_a  + h[:recent][0..3]).uniq
    h
  end

  def update_local_idenfifiers
    Identifier::Local.update_cached(self)
  end

end

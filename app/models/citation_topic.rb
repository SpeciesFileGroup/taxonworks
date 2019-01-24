# A citation topic links a Topic to a Citation. It is the assertion that a Citation contains
# information on a specific topic for the Citations subject. For example:
#
# Otu     Citation (Source)           CitationTopic  Topic (= ControlledVocabularyTerm of type "Topic")
# Aus has Citation Smith (1920), with CitationTopics "Biology" on pages 21,22.
#
# This set of data asserts that the concept of Aus, an OTU, is circumscribed/described in full or part in Smith (1920), and that
# one of the subjects of that circumscription is its "Biology", specifically found on pages 21,22.
#
# @!attribute topic_id
#   @return [Integer]
#     the Topic in the specific citation
#
# @!citation_id
#   @return [Integer]
#     The citation (links subject to source)
#
# @!attribute pages
#   @return [String]
#     the pages that the specific Topic is listed on
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class CitationTopic < ApplicationRecord

  include Housekeeping
  include Shared::IsData

  belongs_to :topic, inverse_of: :citation_topics
  belongs_to :citation, inverse_of: :citation_topics

  # DO NOT INCLUDE (borks accepts_nested_attributes), handled with not null in DB
  # validates_presence_of :topic_id  :citation_id

  validates_uniqueness_of :topic_id, scope: :citation_id
  accepts_nested_attributes_for :topic, allow_destroy: true, reject_if: :reject_topic

  protected

  def reject_topic(attributed)
    attributed['name'].blank? || attributed['definition'].blank?
  end

end

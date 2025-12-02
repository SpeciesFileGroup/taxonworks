# Text to be printed.
#
# @!attribute text
#   @return [String]
#    The text of the label.
#
# @!attribute total
#   @return [Integer]
#     The number of copies to print
#
# @!attribute style
#   @return [String]
#     The unique name for a corresponding CSS class. # TODO: reference vocabulary file
#
# @!attribute label_object_id
#   @return [String]
#     Polymorphic id
#
# @!attribute label_object_type
#   @return [String]
#     Polymorphic type
#
# @!attribute is_copy_edited
#   @return [Boolean, nil]
#     A curator assertion that the label has been checked and is ready for print.  Not required prior to printing.
#
# @!attribute is_printed
#   @return [Boolean, nil]
#     When true the label has been sent to the printed, as asserted by the curator.
#
class Label < ApplicationRecord

  include Housekeeping
  include Shared::Notes
  include Shared::Tags
  include Shared::Depictions
  include Shared::PolymorphicAnnotator
  include Shared::IsData

  polymorphic_annotates('label_object', presence_validate: false)

  ignore_whitespace_on(:text)

  attr_accessor :text_method

  before_validation :stub_text, if: Proc.new { |c| c.text_method.present? }

  after_save :set_text, if: Proc.new { |c| c.text_method.present? }

  validates_presence_of :text, :total

  scope :unprinted, -> { where(is_printed: false) }

  def is_generated?
    false
  end

  def self.batch_create(collecting_event_query_params, label_attribute, total)
    q = Queries::CollectingEvent::Filter.new(collecting_event_query_params).all

    label_attribute = (label_attribute || '').to_sym
    if ![:verbatim_label, :document_label, :print_label].include?(label_attribute)
      raise TaxonWorks::Error, "Invalid label choice: '#{label_attribute}'"
    end

    max = 1_000
    if q.count > max
      raise TaxonWorks::Error, "At most #{max} labels can be created at once"
    end

    total = [total, 1].max
    begin
      i = 0
      # Can't think of why this should ever fail, so we'll just
      # fail-on-first-error.
      q.each do |ce|
        label_text = ce[label_attribute]
        next if label_text.blank?

        Label.create!(
          text: label_text,
          total:,
          label_object_id: ce.id,
          label_object_type: ce.class.name,
        )
        i += 1
      end
    rescue ActiveRecord::RecordInvalid => e
      raise TaxonWorks::Error, "Batch create failed after #{i}/#{q.count} creates! '#{e.errors.full_messages.join('; ')}'"
    end
  end

  protected

  def set_text
    update_column(:text, label_object.reload.send(text_method.to_sym))
  end

  def stub_text
    assign_attributes(text:  'STUB')
  end

end

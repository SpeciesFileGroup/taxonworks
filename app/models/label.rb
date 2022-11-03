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

  polymorphic_annotates('label_object')

  ignore_whitespace_on(:text)

  attr_accessor :text_method

  before_validation :stub_text, if: Proc.new { |c| c.text_method.present? }

  after_save :set_text, if: Proc.new { |c| c.text_method.present? }

  validates_presence_of :text, :total

  scope :unprinted, -> { where(is_printed: false) }

  def is_generated?
    false
  end

  protected

  def set_text
    update_column(:text, label_object.reload.send(text_method.to_sym))
  end

  def stub_text
    assign_attributes(text:  'STUB')
  end

end

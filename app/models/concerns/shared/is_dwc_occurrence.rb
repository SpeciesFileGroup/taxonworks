# Shared code for data classes that can be serialized as DwcOccurrence records
#
module Shared::IsDwcOccurrence
  extend ActiveSupport::Concern

  included do
    delegate :persisted?, to: :dwc_occurrence, prefix: :dwc_occurrence, allow_nil: true

    # @return Boolean, nil
    #   when true prevents automatic dwc_index from being created
    attr_accessor :no_dwc_occurrence

    has_one :dwc_occurrence, as: :dwc_occurrence_object, inverse_of: :dwc_occurrence_object

    after_save :set_dwc_occurrence, unless: -> { no_dwc_occurrence }

    scope :dwc_indexed, -> {joins(:dwc_occurrence)}
    scope :dwc_not_indexed, -> { includes(:dwc_occurrence).where(dwc_occurrences: {id: nil}) }
  end

  module ClassMethods
    def dwc_attribute_vector
      t = ::DwcOccurrence.arel_table 
      s = self.arel_table
      k = self::DwcExtensions::DWC_OCCURRENCE_MAP.keys.sort
      [ s[:id], t[:id], t[:dwc_occurrence_object_type], *k.collect{|a| t[a]} ]
    end

    def dwc_attribute_vector_names
      ["#{self.name.tableize}_id", 'dwc_occurrence_id'] + dwc_attribute_vector[2..-1].collect{|a| a.name}
    end
  end

  # @return [DwcOccurrence]
  #   always touches the database
  def set_dwc_occurrence
    retried = false
    begin
      if dwc_occurrence_persisted?
        dwc_occurrence.update_columns(dwc_occurrence_attributes)
      else
        create_dwc_occurrence!(dwc_occurrence_attributes)
      end
    rescue ActiveRecord::ActiveRecordError
      unless retried
        retried = true
        dwc_occurrence&.reload
        retry
      else
        raise
      end
    end
    dwc_occurrence
  end

  def dwc_occurrence_attributes
    a = {}
    self.class::DWC_OCCURRENCE_MAP.each do |k,v|
      a[k] = send(v)
    end

    a[:project_id] = project_id
    a[:created_by_id] = created_by_id
    a[:updated_by_id] = updated_by_id
    a
  end

  # @return [Array]
  #   an array of the values presently computed for this occurrence
  def dwc_occurrence_attribute_values
    [id, dwc_occurrence.id] + self.class.dwc_attribute_vector[2..-1].collect{|a| a.name}.collect{|f| dwc_occurrence.send(f) }
  end

  # @return [DwcOccurrence]
  #   does not rebuild if exists
  def get_dwc_occurrence
    # TODO: why are extra queries fired if this is fired?
    if dwc_occurrence_persisted?
      dwc_occurrence
    else
      set_dwc_occurrence
    end
  end

end

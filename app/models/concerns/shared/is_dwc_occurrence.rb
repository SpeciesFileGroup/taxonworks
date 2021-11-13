# Shared code for data classes that can be serialized as DwcOccurrence records
#
module Shared::IsDwcOccurrence
  extend ActiveSupport::Concern

  # These probably belong in a global helper
  DWC_DELIMITER = ' | '

  VIEW_EXCLUSIONS = [
    :footprintWKT
  ]

  included do
    delegate :persisted?, to: :dwc_occurrence, prefix: :dwc_occurrence, allow_nil: true

    # @return Boolean, nil
    #   when true prevents automatic dwc_index from being created
    attr_accessor :no_dwc_occurrence

    has_one :dwc_occurrence, as: :dwc_occurrence_object, inverse_of: :dwc_occurrence_object

    after_save :set_dwc_occurrence, unless: -> { no_dwc_occurrence }

    scope :dwc_indexed, -> {joins(:dwc_occurrence)}
    scope :dwc_not_indexed, -> { where.missing(:dwc_occurrence) }
  end

  module ClassMethods

    # @return Array of Arel::Attributes::Attribute
    def dwc_attribute_vector(mode = :all)
      t = ::DwcOccurrence.arel_table
      s = self.arel_table

      k = self::DWC_OCCURRENCE_MAP.keys.sort

      if mode.to_sym == :view
        k = k - self::VIEW_EXCLUSIONS
      end

      [ s[:id], t[:id], t[:dwc_occurrence_object_type], *k.collect{|a| t[a]} ]
    end

    def dwc_attribute_vector_names(mode = :all)
      ["#{self.name.tableize}_id", 'dwc_occurrence_id'] + dwc_attribute_vector(mode)[2..-1].collect{|a| a.name}
    end
  end

  # @return [DwcOccurrence]
  #   always touches the database
  def set_dwc_occurrence
    retried = false
    begin
      if dwc_occurrence_persisted?
        dwc_occurrence.generate_uuid_if_required
        dwc_occurrence.update_columns(dwc_occurrence_attributes)
        dwc_occurrence.touch(:updated_at)
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

  def dwc_occurrence_attributes(taxonworks_fields = true)
    a = {}
    self.class::DWC_OCCURRENCE_MAP.each do |k,v|
      a[k] = send(v)
    end
    a[:occurrenceID] = dwc_occurrence_id

    if taxonworks_fields
      a[:project_id] = project_id

      # TODO: semantics of these may need to be revisited, particularly updated_by_id
      a[:created_by_id] = created_by_id
      a[:updated_by_id] = updated_by_id

      a[:updated_at] = Time.now # !! Not applied via this key, but kept for reference, see `touch` in `set_dwc_occurrence`
    end

    a
  end

  # TODO: CHECK when hit
  def dwc_occurrence_id
    dwc_occurrence&.occurrence_identifier&.cached
  end

  # @return [Array]
  #   an array of the values presently computed for this occurrence
  def dwc_occurrence_attribute_values(mode = :all)
    [id, dwc_occurrence.id] + self.class.dwc_attribute_vector(mode)[2..-1].collect{|a| a.name}.collect{|f| dwc_occurrence.send(f) }
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

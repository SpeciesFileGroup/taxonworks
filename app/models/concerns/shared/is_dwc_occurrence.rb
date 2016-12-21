# Shared code for data classes that can be serialized as DwcOccurrence records
#
module Shared::IsDwcOccurrence

  extend ActiveSupport::Concern
  
  included do
    delegate :persisted?, to: :dwc_occurrence, prefix: :dwc_occurrence, allow_nil: true

    has_one :dwc_occurrence, as: :dwc_occurrence_object
    attr_accessor :generate_dwc_occurrence
    after_save :set_dwc_occurrence, if: 'generate_dwc_occurrence' 
  end

  module ClassMethods
  end

  def set_dwc_occurrence
    if dwc_occurrence_persisted?
      dwc_occurrence.update(dwc_occurrence_attributes)
    else      
      create_dwc_occurrence(dwc_occurrence_attributes)
    end
    dwc_occurrence
  end

  def dwc_occurrence_attributes
    a = {}  
    self.class::DWC_OCCURRENCE_MAP.each do |k,v|
      a[k] = send(v)
    end
    a
  end

  def get_dwc_occurrence
    if dwc_occurrence_persisted?
      dwc_occurrence
    else
      set_dwc_occurrence
    end
  end

end

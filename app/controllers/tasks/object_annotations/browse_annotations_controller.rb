class Tasks::BrowseAnnotationsController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index

  end

  def get_type
    render({json: params})
  end

  def get_type_list
    render(json: {
        "tags": "Tags (by Keyword)",
        "data_attributes": "Data attribues (by Predicates)",
        "confidence": "Confidence (by Confidence Level)",
        "alternate_values": "Alternate values",
        "notes": "notes"
    }
    )
  end

  def annotation_on
    render({json: params})
  end

  def annotation_for
    render({json: params})
  end

  def process_submit
    render({json: params})
  end

  def set_model
    render({json: params})
  end

  def get_model_list
    render(json: {
        otu: 'by OTU',
        taxon_name: 'by Taxon Name',
        specimen: 'by Specimen'}
    )
  end

  def get_dates
    render({json: params})
  end

  def get_logic
    render({json: params})
  end
end
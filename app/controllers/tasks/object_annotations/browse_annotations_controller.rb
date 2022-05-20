class Tasks::BrowseAnnotationsController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
  end

  def get_type
    render({json: params})
  end

  def get_type_list
    render(json: AnnotationsController.types)
  end

  def annotation_on
    render({json: params})
  end

  def annotation_for
    render({json: params})
  end

  def get_for_list
    render(json: {
      "tag": "selected keyword)",
      "data_attribute": "selected predicate",
      "alternate_value": "selected alternate value",
      "notes": "notes"
    })
  end

  def process_submit
    render({json: params})
  end

  def set_model
    render({json: params})
  end

  def get_model_list
    render(
      json: {
        otu: 'by OTU',
        taxon_name: 'by Taxon Name',
        specimen: 'by Specimen'}
    )
  end

  def set_dates
    render({json: params})
  end

  def set_logic
    render({json: params})
  end
end

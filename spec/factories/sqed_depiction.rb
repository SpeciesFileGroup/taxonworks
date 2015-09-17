FactoryGirl.define do
  factory :sqed_depiction, traits: [:housekeeping] do
    factory :valid_sqed_depiction do
      association :depiction, factory: :valid_depiction
      boundary_color "green"
      boundary_finder "Sqed::BoundaryFinder::ColorLineFinder"
      has_border false
      layout "cross"
      metadata_map "{ 0 => curator_metadata, 1 => identifier, 2 => image_registration, 3 => annotated_specimen }" # notice whitespace critical!  
      result_boundaries ""
      result_text ""
    end
  end
end

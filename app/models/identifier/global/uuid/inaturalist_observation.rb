class Identifier::Global::Uuid::InaturalistObservation < Identifier::Global::Uuid
  # validate :object_is_field_occurrence

  def url
    "https://www.inaturalist.org/observations/#{identifier}"
  end
end

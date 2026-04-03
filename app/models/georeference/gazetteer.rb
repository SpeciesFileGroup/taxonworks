class Georeference::Gazetteer < Georeference
  attr_accessor :gazetteer_id

  before_validation :set_geographic_item_from_gazetteer

  validate :gazetteer_exists, if: -> { gazetteer_id.present? }

  def dwc_georeference_attributes(h = {})
    super(h)
    h.merge!(
      georeferenceSources: "TaxonWorks user-added Gazetteer.",
      georeferenceRemarks: "Created from a shape in TaxonWorks that a user added to the system.",
      geodeticDatum: nil
    )
    h[:georeferenceProtocol] = "User selection from the system's user-added shapes." if h[:georeferenceProtocol].blank?
    h
  end

  private

  def gazetteer
    return @gazetteer if defined?(@gazetteer)

    @gazetteer = ::Gazetteer.find_by(id: gazetteer_id)
  end

  def gazetteer_exists
    errors.add(:gazetteer_id, :invalid) if gazetteer.nil?
  end

  def set_geographic_item_from_gazetteer
    self.geographic_item = gazetteer&.geographic_item if gazetteer_id.present?
  end
end

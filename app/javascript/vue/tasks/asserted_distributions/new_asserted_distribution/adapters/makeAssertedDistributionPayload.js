export function makeAssertedDistributionPayload({
  ad,
  object,
  shape,
  citation
}) {
  return {
    id: ad.id,
    asserted_distribution_object_type: object.objectType,
    asserted_distribution_object_id: object.id,
    is_absent: ad.isAbsent,
    asserted_distribution_shape_type: shape.shapeType,
    asserted_distribution_shape_id: shape.id,
    citations_attributes: [
      {
        id: citation.id,
        source_id: citation.source_id,
        is_original: citation.is_original,
        pages: citation.pages
      }
    ]
  }
}

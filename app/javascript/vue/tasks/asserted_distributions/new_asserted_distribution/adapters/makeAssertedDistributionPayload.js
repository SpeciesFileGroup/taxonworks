export function makeAssertedDistributionPayload({
  ad,
  otu,
  assertedDistributionShape,
  citation
}) {
  return {
    id: ad.id,
    otu_id: otu.id,
    is_absent: ad.isAbsent,
    asserted_distribution_shape_id: assertedDistributionShape.id,
    asserted_distribution_shape_type: 'GeographicArea', // TODO support GZ as well
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

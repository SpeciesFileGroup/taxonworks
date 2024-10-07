export function makeAssertedDistributionPayload({
  ad,
  otu,
  geographicArea,
  citation
}) {
  return {
    id: ad.id,
    otu_id: otu.id,
    is_absent: ad.isAbsent,
    geographic_area_id: geographicArea.id,
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

import { TaxonDetermination } from 'routes/endpoints'

export default function (coId) {
  const payload = {
    otu_id: this.otu.id,
    biological_collection_object_id: coId
  }

  return TaxonDetermination.create({ taxon_determination: payload })
}

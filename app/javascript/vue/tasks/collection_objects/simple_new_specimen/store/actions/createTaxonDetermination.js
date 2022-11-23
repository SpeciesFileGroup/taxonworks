import { TaxonDetermination } from 'routes/endpoints'

export default function () {
  const payload = {
    otu_id: this.otu.id,
    biological_collection_object_id: this.createdCO.id
  }

  TaxonDetermination.create({ taxon_determination: payload })
}

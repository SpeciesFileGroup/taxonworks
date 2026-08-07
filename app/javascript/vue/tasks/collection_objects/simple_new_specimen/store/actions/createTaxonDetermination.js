import { TaxonDetermination } from '@/routes/endpoints'
import { COLLECTION_OBJECT } from '@/constants'

export default function (coId) {
  const payload = {
    taxon_determination: {
      otu_id: this.otu.id,
      taxon_determination_object_id: coId,
      taxon_determination_object_type: COLLECTION_OBJECT
    }
  }

  return TaxonDetermination.create(payload)
}

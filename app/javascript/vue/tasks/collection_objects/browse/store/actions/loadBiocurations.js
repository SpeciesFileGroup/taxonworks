import { BiocurationClassification, ControlledVocabularyTerm } from 'routes/endpoints'
import { BIOCURATION_GROUP } from 'constants/index.js'

export default async ({ state }, coId) => {
  const biocurationGroups = (await ControlledVocabularyTerm.where({ type: [BIOCURATION_GROUP] })).body
  const biocurations = (await BiocurationClassification.where({ biological_collection_object_id: coId })).body


}

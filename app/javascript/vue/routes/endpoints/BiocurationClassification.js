import baseCRUD from './base'

const permitParams = {
  biocuration_classification: {
    biocuration_class_id: String,
    biological_collection_object_id: String
  }
}

export const BiocurationClassification = {
  ...baseCRUD('biocuration_classifications', permitParams)
}

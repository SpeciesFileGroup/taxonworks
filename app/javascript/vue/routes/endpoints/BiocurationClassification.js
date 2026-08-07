import baseCRUD from './base'

const permitParams = {
  biocuration_classification: {
    biocuration_class_id: String,
    biocuration_classification_object_id: String,
    biocuration_classification_object_type: String
  }
}

export const BiocurationClassification = {
  ...baseCRUD('biocuration_classifications', permitParams)
}

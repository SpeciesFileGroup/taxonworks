import baseCRUD from './base'

const permitParams = {
  document: {
    document_file: String,
    initialize_start_page: String,
    is_public: Boolean
  }
}

export const Document = {
  ...baseCRUD('documents', permitParams)
}

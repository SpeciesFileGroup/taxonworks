import baseCRUD from './base'

const permitParams = {
  namespace: {
    id: Number,
    institution: String,
    name: String,
    short_name: String,
    verbatim_short_name: String,
    delimiter: String,
    is_virtual: Boolean
  }
}

export const Namespace = {
  ...baseCRUD('namespaces', permitParams)
}

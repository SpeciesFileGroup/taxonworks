import baseCRUD from './base'

const permitParams = {
  otu: {
    id: Number,
    name: String,
    taxon_name_id: Number
  }
}

export const Otu = {
  ...baseCRUD('otus', permitParams)
}

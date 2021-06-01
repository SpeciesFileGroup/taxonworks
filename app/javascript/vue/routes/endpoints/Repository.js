import baseCRUD from './base'

const permitParams = {
  repository: {
    name: String,
    url: String,
    acronym: String,
    status: String,
    institutional_LSID: String,
    is_index_herbarioum_record: Boolean
  }
}

export const Repository = {
  ...baseCRUD('repositories', permitParams)
}

import baseCRUD from './base'

const permitParams = {
  download: {
    is_public: Boolean
  }
}

export const Download = {
  ...baseCRUD('downloads', permitParams)
}

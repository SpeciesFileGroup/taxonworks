import baseCRUD from './base'

const permitParams = {
  protocol: {
    id: Number,
    name: String,
    short_name: String,
    description: String
  }
}

export const Protocol = {
  ...baseCRUD('protocols', permitParams),
}

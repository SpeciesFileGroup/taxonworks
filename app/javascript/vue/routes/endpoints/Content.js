import baseCRUD, { annotations } from './base'

const permitParams = {
  content: {
    text: String,
    otu_id: Number,
    topic_id: Number
  }
}

export const Content = {
  ...baseCRUD('contents', permitParams),
  ...annotations('contents')
}

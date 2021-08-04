import baseCRUD, { annotations } from './base'

const permitParams = {
  citation_topic: {
    citation_id: Number,
    topic_id: Number
  }
}

export const CitationTopic = {
  ...baseCRUD('citation_topics', permitParams),
  ...annotations('citation_topics')
}

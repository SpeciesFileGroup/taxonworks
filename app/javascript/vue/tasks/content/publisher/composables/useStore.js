
import { Content } from 'routes/endpoints'
import { reactive, toRefs } from 'vue'

const state = reactive({
  topics: [],
  contents: {}
})

function getTopicById (topicId) {
  return Object.entries(state.topics).find(([_, topic]) => topic.topic_id === topicId)[1]
}

export const useStore = () => {
  const actions = {

    requestTopics: async () => {
      const { body } = await Content.summary()

      state.topics = body
    },

    requestTopicTable: async (topicId) => {
      const { body } = await Content.topicTable({ topic_id: topicId, extend: ['public_content'] })

      state.contents[topicId] = body
    },

    updateContent: async ({ contentId, isPublic, topicId }) => {
      const contentList = state.contents[topicId]
      const index = contentList.findIndex(content => content.id === contentId)
      const topic = getTopicById(topicId)
      const { body } = await Content.update(
        contentId, {
          content: { is_public: isPublic },
          extend: ['public_content']
        }
      )

      if (isPublic) {
        topic.unpublished--
        topic.published++
      } else {
        topic.unpublished++
        topic.published--
      }

      Object.assign(contentList[index], {
        is_public: body.is_public,
        public_text: body.public_content.text
      })
    },

    publishAll: async (topicId) => {
      const { body } = await Content.publishAll(topicId)
      const topic = getTopicById(topicId)

      state.contents[topicId] = body
      topic.unpublished = 0
      topic.published = body.length
    },

    unpublishAll: async (topicId) => {
      const { body } = await Content.unpublishAll(topicId)
      const topic = getTopicById(topicId)

      state.contents[topicId] = body
      topic.unpublished = body.length
      topic.published = 0
    }
  }

  const getters = {
    getContentsByTopicId: (id) => state.contents[id]
  }

  return {
    ...toRefs(state),
    ...actions,
    ...getters
  }
}

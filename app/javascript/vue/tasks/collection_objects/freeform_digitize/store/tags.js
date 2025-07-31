import { defineStore } from 'pinia'
import { addToArray } from '@/helpers'

export default defineStore('tags', {
  state: () => ({
    tags: []
  }),

  actions: {
    addTag(tag) {
      addToArray(
        this.tags,
        {
          id: tag.id,
          label: tag.object_tag
        },
        { property: 'keywordId' }
      )
    },
    removeTag(index) {
      this.tags.splice(index, 1)
    }
  }
})

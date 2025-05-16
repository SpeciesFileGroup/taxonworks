import { defineStore } from 'pinia'

export default defineStore('content', {
  state: () => {
    return {
      content: {
        id: undefined,
        global_id: undefined,
        text: ''
      },
      topic: undefined,
      otu: undefined,

      panels: {
        figures: false,
        citations: false
      },
      depictions: [],
      citations: []
    }
  },

  actions: {
    setContent(data) {
      this.content.id = data.id
      this.content.global_id = data.global_id
      this.content.text = data.text
    }
  }
})

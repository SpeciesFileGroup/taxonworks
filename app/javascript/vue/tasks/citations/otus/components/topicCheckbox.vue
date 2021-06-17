<template>
  <div>
    <label>
      <input
        v-model="checked"
        type="checkbox"
        @click="setOrRemoveTopic()"
        :disabled="disable">
      {{ topic.name }}
    </label>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { CitationTopic } from 'routes/endpoints'

export default {
  computed: {
    disable () {
      return this.$store.getters[GetterNames.ObjectsSelected]
    },
    topicsSelected () {
      return this.$store.getters[GetterNames.GetSetTopics]
    }
  },

  props: {
    topic: {
      type: Object
    }
  },

  data () {
    return {
      checked: false,
      citation_topic: {
        topic_id: undefined,
        citation_id: undefined
      }
    }
  },

  watch: {
    topicsSelected:{
      handler () {
        this.checkTopics()
      },
      deep: true
    }
  },

  methods: {
    checkTopics () {
      let checked = false

      this.$store.getters[GetterNames.GetSetTopics].forEach(item => {
        if (item.topic_id === this.topic.id) {
          checked = true
          this.citation_topic = item
        }
      })

      this.checked = checked
    },
    setOrRemoveTopic () {
      if (!this.checked) {
        this.createCitation()
      } else {
        this.removeCitationTopic()
      }
    },
    createCitation () {
      const citation_topic = {
        topic_id: this.topic.id,
        citation_id: this.$store.getters[GetterNames.GetCitationSelected].id
      }

      CitationTopic.create({ citation_topic }).then(response => {
        this.$store.commit(MutationNames.AddTopicSelected, response.body)
      })
    },
    removeCitationTopic () {
      CitationTopic.destroy(this.citation_topic.id).then(() => {
        this.$store.commit(MutationNames.RemoveTopicSelected, this.citation_topic.id)
      })
    }
  }
}
</script>

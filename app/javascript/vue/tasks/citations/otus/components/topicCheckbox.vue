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
  import AjaxCall from 'helpers/ajaxCall'

  export default {

    computed: {
      disable() {
        return this.$store.getters[GetterNames.ObjectsSelected]
      },
      topicsSelected() {
        return this.$store.getters[GetterNames.GetSetTopics]
      }
    },
    props: {
      topic: {
        type: Object
      }
    },
    data: function () {
      return {
        checked: false,
        citation_topic: {
          topic_id: undefined,
          citation_id: undefined
        }
      }
    },

    watch: {
      topicsSelected: function () {
        this.checkTopics()
      }
    },

    methods: {
      checkTopics: function () {
        let that = this
        let checked = false

        this.$store.getters[GetterNames.GetSetTopics].forEach(function (item, index) {
          if (item.topic_id == that.topic.id) {
            checked = true
            that.citation_topic = item
          }
        })

        that.checked = checked
      },
      setOrRemoveTopic: function () {
        if (!this.checked) {
          this.createCitation()
        } else {
          this.removeCitationTopic()
        }
      },
      createCitation: function () {
        let citation_topic = {
          topic_id: this.topic.id,
          citation_id: this.$store.getters[GetterNames.GetCitationSelected].id
        }

        AjaxCall('post', '/citation_topics.json', { citation_topic: citation_topic }).then(response => {
          this.$store.commit(MutationNames.AddTopicSelected, response.body)
        })
      },
      removeCitationTopic: function () {
        AjaxCall('delete', '/citation_topics/' + this.citation_topic.id).then(() => {
          this.$store.commit(MutationNames.RemoveTopicSelected, this.citation_topic.id)
        })
      }
    }
  }
</script>

<template>
  <button
    type="button"
    class="button button-default button-select margin-small-bottom"
    @click="isOpen = true"
  >
    {{ buttonLabel }}
  </button>

  <v-modal
    v-if="isOpen"
    @close="isOpen = false"
    :containerStyle="{ width: '600px', height: '70vh' }"
  >
    <template #header>
      <h3>Select Topic</h3>
    </template>
    <template #body>
      <topic-list @onSelect="setTopic" />
    </template>
  </v-modal>
</template>

<script>

import VModal from 'components/ui/Modal.vue'
import TopicList from './TopicList.vue'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  components: {
    TopicList,
    VModal
  },

  data () {
    return {
      isOpen: false
    }
  },

  computed: {
    topic: {
      get () {
        return this.$store.getters[GetterNames.GetTopicSelected]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTopicSelected, value)
      }
    },

    buttonLabel () {
      return this.topic
        ? 'Change Topic'
        : 'Topic'
    }
  },

  methods: {
    setTopic (topic) {
      this.topic = topic
    }
  }
}
</script>

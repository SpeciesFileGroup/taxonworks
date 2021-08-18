<template>
  <div>
    <button
      @click="showModal = true"
      class="button normal-input button-default"
    >
      Select
    </button>
    <modal
      v-if="showModal"
      @close="closeModal()">
      <template #header>
        <h3>Select</h3>
      </template>
      <template #body>
        <div class="flex-wrap-column middle">
          <topic-modal />
          <otu-modal />
          <content-modal />
        </div>
      </template>
    </modal>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import Modal from 'components/ui/Modal.vue'
import TopicModal from '../components/Topic/TopicModal.vue'
import OtuModal from '../components/Otu/OtuModal.vue'
import ContentModal from '../components/Content/ContentModal.vue'

export default {
  name: 'SelectTopicOtu',

  components: {
    Modal,
    ContentModal,
    TopicModal,
    OtuModal
  },

  data () {
    return {
      showModal: true,
      selectedPanel: ''
    }
  },

  computed: {
    topic () {
      return this.$store.getters[GetterNames.GetTopicSelected]
    },

    otu () {
      return this.$store.getters[GetterNames.GetOtuSelected]
    }
  },

  watch: {
    topic (newVal) {
      if (newVal && this.otu) {
        this.showModal = false
      }
    },

    otu (newVal) {
      if (newVal && this.topic) {
        this.showModal = false
      }
    }
  },

  methods: {
    closeModal () {
      if (this.otu && this.topic) {
        this.showModal = false
      }
    }
  }
}
</script>

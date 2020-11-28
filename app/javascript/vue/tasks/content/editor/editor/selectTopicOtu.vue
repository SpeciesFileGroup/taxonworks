<template>
  <div>
    <button
      @click="showModal = true"
      class="button normal-input button-default">Select
    </button>
    <modal
      v-if="showModal"
      @close="closeModal()">
      <h3 slot="header">Select</h3>
      <div slot="body">
        <div class="flex-wrap-column middle">
          <button
            @click="closeAll(), topicPanel()"
            class="button button-default button-select">
            <span v-if="topic">Change topic</span>
            <span v-else>Topic</span>
          </button>
          <button
            @click="closeAll(), otuPanel()"
            class="button button-default separate-top button-select">
            <span v-if="otu">Change OTU</span>
            <span v-else>OTU</span>
          </button>
          <button
            @click="closeAll(), recentPanel()"
            class="button button-default separate-top button-select">
            <span>Recent</span>
          </button>
        </div>
      </div>
    </modal>
  </div>
</template>

<script>
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import Modal from 'components/modal.vue'

export default {
  name: 'SelectTopicOtu',
  components: {
    Modal
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
    topic (val, oldVal) {
      if (val !== oldVal) {
        if (this.otu) {
          this.showModal = false
        }
      }
      this.closeAll()
    },
    otu (val, oldVal) {
      if (val !== oldVal) {
        if (this.topic) {
          this.showModal = false
        }
      }
      this.closeAll()
    }
  },
  methods: {
    closeAll () {
      TW.views.shared.slideout.closeSlideoutPanel('[data-panel-name="recent_list"]')
      TW.views.shared.slideout.closeSlideoutPanel('[data-panel-name="topic_list"]')
      this.$store.commit(MutationNames.OpenOtuPanel, false)
    },
    topicPanel () {
      TW.views.shared.slideout.openSlideoutPanel('[data-panel-name="topic_list"]')
    },
    recentPanel () {
      TW.views.shared.slideout.openSlideoutPanel('[data-panel-name="recent_list"]')
    },
    otuPanel () {
      this.$store.commit(MutationNames.OpenOtuPanel, true)
    },
    closeModal () {
      this.closeAll()
      if (this.otu && this.topic) {
        this.showModal = false
      }
    }
  }
}
</script>

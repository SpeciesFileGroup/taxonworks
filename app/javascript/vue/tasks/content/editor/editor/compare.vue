<template>
  <div :class="{ disabled : !contents.length }">
    <div
      class="item flex-wrap-column middle menu-button"
      @click="showModal = !!contents.length">
      <span
        data-icon="compare"
        class="big-icon"/>
      <span class="tiny_space">Compare</span>
    </div>
    <modal
      v-if="showModal"
      id="compare-modal"
      @close="showModal = false">
      <template #header>
        <h3>Compare content</h3>
      </template>
      <template #body>
        <ul class="no_bullets">
          <li
            v-for="item in contents"
            :key="item.id"
            @click="compareContent(item)">
            <div class="clone-content-text">{{ item.text }}</div>
            <span v-html="item.topic.object_tag + ' - ' + item.otu.object_tag"/>
          </li>
        </ul>
      </template>
    </modal>
  </div>
</template>

<script>

import Modal from 'components/ui/Modal.vue'
import { GetterNames } from '../store/getters/getters'
import { Content } from 'routes/endpoints'

export default {
  components: { Modal },

  emits: ['showCompareContent'],

  computed: {
    topic () {
      return this.$store.getters[GetterNames.GetTopicSelected]
    },

    otu () {
      return this.$store.getters[GetterNames.GetOtuSelected]
    },

    content () {
      return this.$store.getters[GetterNames.GetContentSelected]
    },

    disabled () {
      return !this.$store.getters[GetterNames.GetTopicSelected]
    }
  },

  data () {
    return {
      contents: [],
      showModal: false
    }
  },

  watch: {
    topic (newVal, oldVal) {
      if (newVal?.id && newVal.id !== oldVal?.id) {
        this.loadContent()
      } else {
        this.contents = []
      }
    },

    otu (newVal) {
      if (newVal?.id) {
        this.loadContent()
      }
    }

  },

  methods: {
    loadContent () {
      Content.where({ topic_id: this.topic.id }).then(({ body }) => {
        this.contents = this.content?.id
          ? body.filter(c => c.id !== this.content.id)
          : body
      })
    },

    compareContent (content) {
      this.$emit('showCompareContent', content)
      this.showModal = false
    }
  }
}
</script>

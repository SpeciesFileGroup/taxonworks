<template>
  <div :class="{ disabled : !contents.length }">
    <div
      @click="showModal = !!contents.length"
      class="item flex-wrap-column middle menu-button">
      <span
        data-icon="clone"
        class="big-icon"
      />
      <span class="tiny_space">Clone</span>
    </div>
    <modal
      v-if="showModal"
      id="clone-modal"
      @close="showModal = false">
      <template #header>
        <h3>Clone</h3>
      </template>
      <template #body>
        <ul class="no_bullets">
          <li
            v-for="item in contents"
            :key="item.id"
            @click="cloneCitation(item.text)">
            <span data-icon="show">
              <div class="clone-content-text">{{ item.text }}</div>
            </span>
            <span v-html="item.object_tag"/>
          </li>
        </ul>
      </template>
    </modal>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { Content } from 'routes/endpoints'
import Modal from 'components/ui/Modal.vue'

export default {
  name: 'CloneConent',

  components: { Modal },

  emits: ['addCloneCitation'],

  data () {
    return {
      contents: [],
      showModal: false
    }
  },

  computed: {
    topic () {
      return this.$store.getters[GetterNames.GetTopicSelected]
    },

    content () {
      return this.$store.getters[GetterNames.GetContentSelected]
    }
  },

  watch: {
    topic (val) {
      if (val) {
        this.loadContent()
      } else {
        this.contents = []
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

    cloneCitation (text) {
      this.$emit('addCloneCitation', text)
      this.showModal = false
    }
  }
}
</script>

<template>
  <div>
    <button
      @click="openWindow"
      class="button button-default normal-input">
      Create new
    </button>
    <modal
      v-if="showModal"
      @close="showModal = false">
      <template #header>
        <h3>New topic</h3>
      </template>
      <template #body>
        <form
          id="new-topic"
          action=""
        >
          <div class="field flex-separate">
            <input
              type="text"
              v-model="topic.name"
              placeholder="Name">
            <input
              type="color"
              v-model="topic.css_color">
          </div>
          <div class="field">
            <textarea
              v-model="topic.definition"
              placeholder="Definition"/>
          </div>
        </form>
      </template>
      <template #footer>
        <div
          class="flex-separate">
          <input
            class="button normal-input button-submit"
            type="submit"
            @click.prevent="createNewTopic"
            :disabled="(topic.name.length < 2) || (topic.definition.length < 20)"
            value="Create">
        </div>
      </template>
    </modal>
  </div>
</template>

<script>

import { ControlledVocabularyTerm } from 'routes/endpoints'
import Modal from 'components/ui/Modal.vue'

export default {
  components: { Modal },

  emits: ['onCreate'],

  data () {
    return {
      showModal: false,
      topic: this.newTopic()
    }
  },

  methods: {
    openWindow () {
      this.topic = this.newTopic()
      this.showModal = true
    },

    createNewTopic () {
      ControlledVocabularyTerm.create({ controlled_vocabulary_term: this.topic }).then(({ body }) => {
        TW.workbench.alert.create(`${body.name} was successfully created.`, 'notice')
        this.$emit('onCreate', body)
      })
      this.showModal = false
    },

    newTopic () {
      return {
        name: '',
        definition: '',
        type: 'Topic'
      }
    }
  }
}
</script>

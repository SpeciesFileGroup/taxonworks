<template>
  <div>
    <button
      @click="openWindow"
      class="button button-default normal-input">New
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
              v-model="topic.controlled_vocabulary_term.name"
              placeholder="Name">
            <input
              type="color"
              v-model="topic.controlled_vocabulary_term.css_color">
          </div>
          <div class="field">
            <textarea
              v-model="topic.controlled_vocabulary_term.definition"
              placeholder="Definition"/>
          </div>
        </form>
      </template>
      <template #footer>
        <div
          class="flex-separate">
          <input
            class="button normal-input"
            type="submit"
            @click.prevent="createNewTopic"
            :disabled="((topic.controlled_vocabulary_term.name.length < 2) || (topic.controlled_vocabulary_term.definition.length < 2)) ? true : false"
            value="Create">
        </div>
      </template>
    </modal>
  </div>
</template>

<script>
import { MutationNames } from '../store/mutations/mutations'
import { ControlledVocabularyTerm } from 'routes/endpoints'
import Modal from 'components/ui/Modal.vue'

export default {
  components: { Modal },

  data () {
    return {
      showModal: false,
      topic: {
        controlled_vocabulary_term: {
          name: '',
          definition: '',
          type: 'Topic'
        }
      }
    }
  },

  methods: {
    openWindow () {
      this.topic.controlled_vocabulary_term.name = ''
      this.topic.controlled_vocabulary_term.definition = ''
      this.showModal = true
    },
    createNewTopic () {
      ControlledVocabularyTerm.create(this.topic).then(({ body }) => {
        TW.workbench.alert.create(`${body.name} was successfully created.`, 'notice')
        this.$parent.topics.push(body)
        this.$store.commit(MutationNames.AddToRecentTopics, body)
      })
      this.showModal = false
    }
  }
}
</script>

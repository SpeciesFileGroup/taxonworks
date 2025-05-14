<template>
  <div>
    <button
      @click="openWindow"
      class="button button-default normal-input"
    >
      Create new
    </button>
    <VModal
      v-if="isModalVisible"
      @close="isModalVisible = false"
    >
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
              placeholder="Name"
            />
            <input
              type="color"
              v-model="topic.css_color"
            />
          </div>
          <div class="field">
            <textarea
              v-model="topic.definition"
              placeholder="Definition"
            />
          </div>
        </form>
      </template>
      <template #footer>
        <div class="flex-separate">
          <input
            class="button normal-input button-submit"
            type="submit"
            @click.prevent="createNewTopic"
            :disabled="topic.name.length < 2 || topic.definition.length < 20"
            value="Create"
          />
        </div>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { ControlledVocabularyTerm } from '@/routes/endpoints'
import VModal from '@/components/ui/Modal.vue'

const emit = defineEmits(['create'])

const topic = newTopic()

const isModalVisible = ref(false)

function openWindow() {
  topic.value = newTopic()
  isModalVisible.value = true
}

function createNewTopic() {
  ControlledVocabularyTerm.create({
    controlled_vocabulary_term: topic.value
  }).then(({ body }) => {
    TW.workbench.alert.create(
      `${body.name} was successfully created.`,
      'notice'
    )
    emit('create', body)
  })
  isModalVisible.value = false
}

function newTopic() {
  return {
    name: '',
    definition: '',
    type: 'Topic'
  }
}
</script>

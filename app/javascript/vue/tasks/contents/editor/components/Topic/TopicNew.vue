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
              rows="4"
              placeholder="Definition"
            />
          </div>
        </form>
      </template>
      <template #footer>
        <VBtn
          color="create"
          medium
          @click.prevent="createNewTopic"
          :disabled="isDisabled"
        >
          Create
        </VBtn>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { ControlledVocabularyTerm } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'

const emit = defineEmits(['create'])

const topic = ref(newTopic())

const isDisabled = computed(
  () => topic.value.name.length < 2 || topic.value.definition.length < 20
)

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

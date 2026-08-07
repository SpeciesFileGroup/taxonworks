<template>
  <div>
    <VBtn
      color="primary"
      medium
      @click="openModal"
    >
      New
    </VBtn>
    <VModal
      v-if="isModalVisible"
      @close="isModalVisible = false"
    >
      <template #header>
        <h3>Create property</h3>
      </template>
      <template #body>
        <div class="field label-above">
          <label>Name</label>
          <input
            class="full_width"
            v-model="cvt.name"
            type="text"
          />
        </div>
        <div class="field label-above">
          <label>Definition</label>
          <textarea
            class="full_width"
            v-model="cvt.definition"
            rows="5"
          />
        </div>
        <div class="field label-above">
          <label>URI</label>
          <input
            class="full_width"
            v-model="cvt.uri"
            type="text"
          />
        </div>
        <div class="field label-above">
          <label>Label color</label>
          <input
            v-model="cvt.css_color"
            type="color"
          />
        </div>
        <VBtn
          medium
          color="create"
          @click="save"
        >
          Save
        </VBtn>
      </template>
    </VModal>
    <VSpinner
      v-if="isSaving"
      full-screen
      lengend="Saving property..."
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { ControlledVocabularyTerm } from '@/routes/endpoints'
import VModal from '@/components/ui/Modal'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const emit = defineEmits(['save'])

const cvt = ref(resetCVT())
const isModalVisible = ref(false)
const isSaving = ref(false)

function openModal() {
  isModalVisible.value = true
  cvt.value = resetCVT()
}

function save() {
  const saveRecord = cvt.value.id
    ? ControlledVocabularyTerm.update(cvt.value.id, {
        controlled_vocabulary_term: cvt.value
      })
    : ControlledVocabularyTerm.create({
        controlled_vocabulary_term: cvt.value
      })

  isSaving.value = true

  saveRecord
    .then((response) => {
      emit('save', response.body)
      isModalVisible.value = false
      cvt.value = resetCVT()
    })
    .catch(() => {})
    .finally(() => {
      isSaving.value = false
    })
}

function resetCVT() {
  return {
    id: undefined,
    type: 'BiologicalProperty',
    name: undefined,
    definition: undefined,
    uri: undefined,
    css_color: undefined
  }
}

function setProperty(property) {
  cvt.value = property
  isModalVisible.value = true
}

defineExpose({
  setProperty
})
</script>

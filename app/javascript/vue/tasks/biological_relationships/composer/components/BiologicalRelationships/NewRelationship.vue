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
        <h3>Create biological relationship</h3>
      </template>
      <template #body>
        <div class="field">
          <label>Name</label>
          <br />
          <input
            v-model="biologicalRelationship.name"
            class="full_width"
            type="text"
          />
        </div>
        <div class="field label-above">
          <label>Inverted name</label>
          <input
            v-model="biologicalRelationship.inverted_name"
            class="full_width"
            type="text"
          />
        </div>
        <ul class="no_bullets">
          <li>
            <label>
              <input
                v-model="biologicalRelationship.is_transitive"
                type="checkbox"
              />
              Is transitive
            </label>
          </li>
          <li>
            <label>
              <input
                v-model="biologicalRelationship.is_reflexive"
                type="checkbox"
              />
              Is reflexive
            </label>
          </li>
        </ul>
        <VBtn
          medium
          color="create"
          @click="create"
        >
          Create
        </VBtn>
      </template>
    </VModal>
    <VSpinner
      v-if="isSaving"
      legend="Saving biological relationship..."
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { BiologicalRelationship } from '@/routes/endpoints'
import { extend } from '../constants/extend.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal'
import VSpinner from '@/components/ui/VSpinner.vue'

const emit = defineEmits(['create'])

const biologicalRelationship = ref(newBiologicalRelationship())
const isModalVisible = ref(false)
const isSaving = ref(false)

function create() {
  isSaving.value = true

  BiologicalRelationship.create({
    biological_relationship: biologicalRelationship.value,
    extend
  })
    .then(({ body }) => {
      emit('create', body)
      isModalVisible.value = false
    })
    .finally(() => {
      isSaving.value = false
    })
}

function newBiologicalRelationship() {
  return {
    name: undefined,
    inverted_name: undefined,
    is_transitive: undefined,
    is_reflexive: undefined
  }
}

function openModal() {
  biologicalRelationship.value = newBiologicalRelationship()
  isModalVisible.value = true
}
</script>

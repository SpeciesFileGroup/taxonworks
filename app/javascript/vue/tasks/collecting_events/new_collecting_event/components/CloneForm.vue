<template>
  <VModal
    v-if="isModalVisible"
    @close="() => (isModalVisible = false)"
  >
    <template #header>
      <h3>Clone</h3>
    </template>
    <template #body>
      <VSpinner
        v-if="isCloning"
        full-screen
        legend="Cloning..."
      />
      <p>
        This will clone the current collecting event with the following
        information.
      </p>
      <ul class="no_bullets">
        <li>
          <label>
            <input
              type="checkbox"
              v-model="annotations"
            />
            Copy annotations
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="incrementIdentifier"
            />
            Increment identifier
          </label>
        </li>
      </ul>
      <VBtn
        class="margin-medium-top"
        color="create"
        medium
        @click="clone"
        >Clone</VBtn
      >
    </template>
  </VModal>
  <VBtn
    color="primary"
    medium
    v-bind="attrs"
    @click="() => (isModalVisible = true)"
  >
    Clone
  </VBtn>
</template>

<script setup>
import { computed, ref, useAttrs } from 'vue'
import { CollectingEvent } from '@/routes/endpoints'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import useIdentifierStore from '@/components/Form/FormCollectingEvent/store/identifier.js'
import useStore from '@/components/Form/FormCollectingEvent/store/collectingEvent.js'

const store = useStore()
const identifierStore = useIdentifierStore()

const identifierId = computed(() => identifierStore.identifier.id)

const emit = defineEmits(['clone'])

const annotations = ref(true)
const incrementIdentifier = ref(true)
const isModalVisible = ref(false)
const isCloning = ref(false)
const attrs = useAttrs()

function clone() {
  const payload = {
    annotations: annotations.value,
    incremented_identifier_id:
      incrementIdentifier.value && identifierId.value
        ? identifierId.value
        : null
  }

  isCloning.value = true
  CollectingEvent.clone(store.collectingEvent.id, payload)
    .then(({ body }) => {
      emit('clone', body)
      isModalVisible.value = false
      TW.workbench.alert.create(
        'Collecting event was successfully cloned.',
        'notice'
      )
    })
    .catch(() => {})
    .finally(() => {
      isCloning.value = false
    })
}
</script>

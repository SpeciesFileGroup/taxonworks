<template>
  <VModal
    v-if="isModalVisible"
    @close="() => (isModalVisible = false)"
  >
    <template #header>
      <h3>Clone</h3>
    </template>
    <template #body>
      <p>
        This will clone the current collecting event with the following
        information.
      </p>
      <ul class="no_bullets">
        <li>
          <label>
            <input
              type="checkbox"
              v-modal="annotations"
            />
            Copy annotations
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              :disabled="!identifierId"
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
import { useStore } from 'vuex'
import { ActionNames } from '../store/actions/actions'
import { GetterNames } from '../store/getters/getters'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const store = useStore()

const identifierId = computed(
  () => store.getters[GetterNames.GetIdentifier]?.id
)

const annotations = ref(false)
const incrementIdentifier = ref(false)
const isModalVisible = ref(false)
const attrs = useAttrs()

function clone() {
  const payload = {
    annotations: annotations.value,
    incremented_identifier_id: incrementIdentifier.value
      ? identifierId.value
      : null
  }

  store.dispatch(ActionNames.CloneCollectingEvent, payload)
}
</script>

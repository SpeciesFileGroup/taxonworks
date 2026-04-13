<template>
  <VModal
    v-if="isVisible"
    :container-style="{ 'overflow-y': 'unset' }"
    @close="isVisible = false"
  >
    <template #header>
      <h3>Place item</h3>
    </template>
    <template #body>
      <div v-if="containerId">
        <ContainerItemObject v-model="containerItem" />
        <div class="field">
          <div
            v-if="containerItem.errorOnSave"
            class="feedback feedback-danger"
            v-text="containerItem.errorOnSave"
          />
          <label>Disposition</label>
          <textarea
            class="full_width"
            rows="5"
            v-model="containerItem.disposition"
            @change="() => (containerItem.isUnsaved = true)"
          ></textarea>
        </div>
      </div>
      <p v-else>Save the container to place items.</p>
    </template>
    <template #footer>
      <div
        v-if="containerId"
        class="horizontal-left-content gap-small"
      >
        <VBtn
          medium
          :color="containerId ? 'create' : 'primary'"
          :disabled="!containerItem.objectId"
          @click="
            () => {
              emit('add', containerItem)
              emit('close')
              isVisible = false
            }
          "
        >
          Set
        </VBtn>
        <VBtn
          v-if="containerItem.objectId"
          :color="containerItem.id ? 'destroy' : 'primary'"
          medium
          @click="
            () => {
              emit('remove', containerItem)
              emit('close')
              isVisible = false
            }
          "
        >
          Remove
        </VBtn>
      </div>
    </template>
  </VModal>
</template>

<script setup>
import { ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import ContainerItemObject from './ContainerItemObject.vue'

defineProps({
  containerId: {
    type: [Number, null],
    required: true
  }
})

const emit = defineEmits(['add', 'remove', 'close'])

const isVisible = ref(false)
const containerItem = ref(null)

function show(data) {
  isVisible.value = true
  containerItem.value = {
    ...data
  }
}

defineExpose({
  show
})
</script>

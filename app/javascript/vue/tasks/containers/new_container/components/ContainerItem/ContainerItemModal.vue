<template>
  <VModal
    v-if="isVisible"
    :container-style="{ 'overflow-y': 'unset' }"
    @close="isVisible = false"
  >
    <template #header>
      <h3>Container item</h3>
    </template>
    <template #body>
      <ContainerItemObject v-model="containerItem" />
      <div class="field">
        <label>Disposition</label>
        <textarea
          class="full_width"
          rows="5"
          v-model="containerItem.disposition"
          @change="() => (containerItem.isUnsaved = true)"
        ></textarea>
      </div>
    </template>
    <template #footer>
      <div class="horizontal-left-content gap-small">
        <VBtn
          color="submit"
          medium
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

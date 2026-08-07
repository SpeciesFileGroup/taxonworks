<template>
  <VBtn
    class="button-size"
    color="primary"
    medium
    :disabled="!store.source.id"
    @click="cloneSource"
  >
    Clone
  </VBtn>
  <ConfirmationModal ref="confirmationModalRef" />
</template>

<script setup>
import { ref } from 'vue'
import { useSourceStore } from '../store'
import { useHotkey } from '@/composables'
import platformKey from '@/helpers/getPlatformKey'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const store = useSourceStore()

const confirmationModalRef = ref(null)
const shortcuts = ref([
  {
    keys: [platformKey(), 'c'],
    handler() {
      cloneSource()
    }
  }
])

useHotkey(shortcuts.value)

async function cloneSource() {
  const ok = await confirmationModalRef.value.show({
    title: 'Clone source',
    message:
      'This will clone the current source. Are you sure you want to proceed?',
    confirmationWord: 'CLONE',
    okButton: 'Clone',
    cancelButton: 'Cancel',
    typeButton: 'submit'
  })

  if (ok) {
    store.cloneSource()
  }
}
</script>

<style scoped>
.button-size {
  width: 100px;
}
</style>

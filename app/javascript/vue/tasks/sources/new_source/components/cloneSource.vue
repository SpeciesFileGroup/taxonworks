<template>
  <button
    type="button"
    class="button normal-input button-submit button-size"
    :disabled="!source.id"
    @click="cloneSource"
  >
    Clone
  </button>
  <ConfirmationModal ref="confirmationModalRef" />
</template>

<script setup>
import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'
import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import { useHotkey } from '@/composables'
import platformKey from '@/helpers/getPlatformKey'
import ConfirmationModal from '@/components/ConfirmationModal.vue'

const store = useStore()

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

const source = computed(() => store.getters[GetterNames.GetSource])

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
    store.dispatch(ActionNames.CloneSource)
  }
}
</script>

<style scoped>
.button-size {
  width: 100px;
}
</style>

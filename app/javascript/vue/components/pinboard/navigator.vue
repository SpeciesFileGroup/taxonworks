<template>
  <ModalNavigator
    v-if="isModalVisible"
    @close="() => (isModalVisible = false)"
  />
</template>

<script setup>
import platformKey from '@/helpers/getPlatformKey.js'
import { useHotkey } from '@/composables'
import ModalNavigator from './ModalNavigator.vue'
import { ref, onMounted } from 'vue'

defineOptions({
  name: 'PinboardNavigator'
})

const hotkeys = ref([
  {
    keys: [platformKey(), 'g'],
    preventDefault: true,
    handler() {
      openModal()
    }
  }
])

useHotkey(hotkeys.value)
const isModalVisible = ref()
const defaultItems = ref({})
const selected = ref()

onMounted(() => {
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+g`,
    'Open pinboard navigator',
    'Pinboard'
  )
})

function openModal() {
  defaultItems.value = {}

  document.querySelectorAll('[data-pinboard-section]').forEach((node) => {
    const element = node.querySelector('[data-insert="true"]')
    if (element) {
      defaultItems.value[node.getAttribute('data-pinboard-section')] = {
        id: element.getAttribute('data-pinboard-object-id'),
        label: element.querySelector('a').textContent
      }
    }
  })

  selected.value = undefined
  isModalVisible.value = true
}
</script>

<template>
  <div class="dropdown-content-item">
    <div
      class="cursor-pointer horizontal-left-content gap-small"
      @click="openModal"
    >
      <IconCompass class="w-4 h-4" />
      <span>Pinboard navigator</span>
    </div>
    <teleport to="body">
      <ModalNavigator
        v-if="isModalVisible"
        @close="() => (isModalVisible = false)"
      />
    </teleport>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useHotkey } from '@/composables'
import platformKey from '@/helpers/getPlatformKey.js'
import ModalNavigator from './ModalNavigator.vue'
import IconCompass from '@/components/Icon/IconCompass.vue'

defineOptions({
  name: 'PinboardNavigator'
})

const hotkeys = ref([
  {
    keys: [platformKey(), 'g'],
    preventDefault: true,
    handler: () => {
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
    'Pinboard',
    true
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

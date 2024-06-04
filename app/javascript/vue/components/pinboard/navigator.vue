<template>
  <ModalNavigator
    v-if="isModalVisible"
    @close="() => (isModalVisible = false)"
  />
</template>

<script setup>
import platformKey from '@/helpers/getPlatformKey.js'
import useHotKey from 'vue3-hotkey'
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

useHotKey(hotkeys.value)
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
<style scoped>
.bounce-enter-active {
  animation: bounce-in 1s;
}
.bounce-leave-active {
  animation: bounce-in 1s reverse;
}
@keyframes bounce-in {
  0% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.5) translateX(25%);
  }
  100% {
    transform: scale(1);
  }
}
</style>

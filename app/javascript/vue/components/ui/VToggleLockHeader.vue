<template>
  <div
    class="flex-row gap-small cursor-pointer middle"
    @click="() => toggleHeader()"
  >
    <IconLock
      class="w-4"
      stroke-width="2"
      v-if="!isLocked"
    />
    <IconUnlock
      class="w-4"
      stroke-width="2"
      v-else
    />

    <span>{{ isLocked ? 'Unlock' : 'Lock' }} Header</span>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useHeaderLock, useHotkey } from '@/composables'
import IconLock from '@/components/Icon/IconLock.vue'
import IconUnlock from '@/components/Icon/IconUnlock.vue'
import platformKey from '@/helpers/getPlatformKey.js'

defineOptions({
  name: 'PinboardNavigator'
})

TW.workbench.keyboard.createLegend(
  `${platformKey()}+shift+f`,
  'Toggle Sticky Header',
  'General shortcuts'
)

useHotkey([
  {
    keys: [platformKey(), 'Shift', 'f'],
    preventDefault: true,
    handler: () => {
      toggleHeader()
    }
  }
])

const { isLocked, toggle, lock } = useHeaderLock()

function toggleHeader() {
  toggle()
  localStorage.headerLocked = isLocked.value
}

onMounted(() => {
  if (localStorage.headerLocked === 'true') {
    lock()
  }
})
</script>

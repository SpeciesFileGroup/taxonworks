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
import { watch, ref, onMounted } from 'vue'
import { useHeaderLock } from '@/composables'
import IconLock from '@/components/Icon/IconLock.vue'
import IconUnlock from '@/components/Icon/IconUnlock.vue'

const { isLocked, toggle, unlock, lock } = useHeaderLock()

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

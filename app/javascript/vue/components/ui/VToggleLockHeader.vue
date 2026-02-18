<template>
  <div
    class="flex-row gap-small cursor-pointer middle"
    @click="() => toggle()"
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

const navbarLocked = ref(null)

if (localStorage.headerLocked === 'true') {
  navbarLocked.value = true
} else {
  navbarLocked.value = false
}

watch(navbarLocked, (value) => {
  if (value) {
    lock()
  } else {
    unlock()
  }

  localStorage.setItem('headerLocked', value)
})

onMounted(() => {
  if (navbarLocked.value) {
    lock()
  }
})
</script>

<template>
  <component
    :is="LAYOUT_COMPONENTS[currentLayout]"
  >
    <template #layout>
      <VBtn
        color="primary"
        title="Change layout"
        @click="changeLayout"
      >
        {{ nextLayout }}
      </VBtn>
    </template>
  </component>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import PreviousFuture from './previous_future/app.vue'
import { computed, onBeforeMount, ref } from 'vue'

const LAYOUTS = ['PreviousFuture', 'FullKey']
const LAYOUT_COMPONENTS = {
  PreviousFuture: PreviousFuture,
  FullKey: null,
}

const SettingsStore = {
  layout: 'newLead::layout'
}

const currentLayout = ref(LAYOUTS[0])

const nextLayout = computed(() => {
  const layoutIndex = LAYOUTS.indexOf(currentLayout.value)
  const newIndex = (layoutIndex + 1) % LAYOUTS.length
  return LAYOUTS[newIndex]
})

function changeLayout() {
  currentLayout.value = nextLayout.value
  sessionStorage.setItem(SettingsStore.redirectValid, currentLayout.value)
}

onBeforeMount(() => {
  const value = sessionStorage.getItem(SettingsStore.layout)
  if (value !== null) {
    currentLayout.value = value
  }
})
</script>

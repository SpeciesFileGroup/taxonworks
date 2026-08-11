<template>
  <transition name="fade">
    <UnsavedIndicator
      v-if="unsavedChanges"
      :saving="isSaving"
      size="medium"
    />
  </transition>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../store/getters/getters'
import UnsavedIndicator from '@/components/ui/UnsavedIndicator/UnsavedIndicator.vue'

const store = useStore()

const unsavedChanges = computed(
  () =>
    store.getters[GetterNames.GetLastChange] >
    store.getters[GetterNames.GetLastSave]
)
const isSaving = computed(() => store.getters[GetterNames.GetSaving])
</script>

<style>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.5s;
}
.fade-enter,
.fade-leave-to {
  opacity: 0;
}
</style>

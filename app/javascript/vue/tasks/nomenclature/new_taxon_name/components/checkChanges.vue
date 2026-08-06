<template>
  <transition name="fade">
    <div
      id="check-unsaved"
      class="panel content soft-validation-box"
      v-if="unsavedChanges"
    >
      <div class="horizontal-left-content gap-small middle">
        <IconWarning class="w-4 h-4 text-attention-color" />
        <span v-if="isSaving">Saving... please wait.</span>
        <span v-else>You have unsaved changes.</span>
      </div>
    </div>
  </transition>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../store/getters/getters'
import IconWarning from '@/components/Icon/IconWarning.vue'

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

#check-unsaved {
  bottom: 20px;
  right: 0px;
}
</style>

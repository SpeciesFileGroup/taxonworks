<template>
  <transition name="fade">
    <div
      id="check-unsaved"
      class="panel content soft-validation-box margin-medium-bottom"
      v-if="unsavedChanges"
    >
      <div class="horizontal-left-content gap-small middle">
        <VIcon
          name="attention"
          color="attention"
          small
        />
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
import VIcon from '@/components/ui/VIcon/index.vue'

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

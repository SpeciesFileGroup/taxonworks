<template>
  <transition name="fade">
    <div
      id="check-unsaved"
      class="panel content soft-validation-box"
      v-if="unsavedChanges">
      <span
        v-if="isSaving"
        data-icon="warning">Saving... please wait.
      </span>
      <span
        v-else
        data-icon="warning">You have unsaved changes.
      </span>
    </div>
  </transition>
</template>

<script>

import { GetterNames } from '../store/getters/getters'

export default {
  computed: {
    unsavedChanges () {
      return (this.$store.getters[GetterNames.GetLastChange] > this.$store.getters[GetterNames.GetLastSave])
    },
    isSaving () {
      return this.$store.getters[GetterNames.GetSaving]
    }
  }
}
</script>

<style>
.fade-enter-active, .fade-leave-active {
  transition: opacity .5s
}
.fade-enter, .fade-leave-to {
  opacity: 0
}

#check-unsaved {
  bottom: 20px;
  right: 0px;
}
</style>

<template>
  <div class="save-countdown">
    <transition
      name="save-countdown__duration-bar-animation"
      @after-enter="doSave">
      <div
        v-if="isCountingDown"
        class="save-countdown__duration-bar"/>
    </transition>

    <div
      v-if="!isCountingDown"
      class="save-countdown__status-bar"
      :class="{
        'save-countdown__status-bar--saving': isSaving, 
        'save-countdown__status-bar--failed': failed, 
        'save-countdown__status-bar--saved-at-least-once': savedAtLeastOnce }"/>

    <button
      class="save-countdown__save-button"
      :class="{ 'save-countdown__save-button--showing': isCountingDown }"
      @click="doSave"
      type="button">
      Save Changes
    </button>
  </div>
</template>

<style src="./SaveCountdown.styl" lang="stylus"></style>

<script>
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { ActionNames } from '../../store/actions/actions'

export default {
  name: 'SaveCountdown',

  props: {
    descriptor: {
      type: Object,
      required: true
    }
  },

  data () {
    return {
      isCountingDown: false,
      failed: false
    }
  },

  computed: {
    needsCountdown () {
      return this.$store.getters[GetterNames.DoesDescriptorNeedCountdown](this.$props.descriptor.id)
    },
    isSaving () {
      return this.$props.descriptor.isSaving
    },
    savedAtLeastOnce () {
      return this.$props.descriptor.hasSavedAtLeastOnce
    }
  },

  watch: {
    needsCountdown (needsCountdown) {
      if (needsCountdown) {
        this.isCountingDown = false
        requestAnimationFrame(_ => {
          this.failed = false
          this.isCountingDown = true
          this.$store.commit(MutationNames.CountdownStartedFor, this.$props.descriptor.id)
        })
      }
    }
  },

  methods: {
    doSave () {
      this.isCountingDown = false
      this.$store.dispatch(ActionNames.SaveObservationsFor, this.$props.descriptor.id).then(response => {
        if (response.includes(false)) {
          this.failed = true
        }
      })
    }
  }
}
</script>

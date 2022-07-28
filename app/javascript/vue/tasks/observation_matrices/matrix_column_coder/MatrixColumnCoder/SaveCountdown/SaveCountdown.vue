<template>
  <div class="save-countdown">
    <transition
      name="save-countdown__duration-bar-animation"
      @after-enter="doSave"
    >
      <div
        v-if="isCountingDown"
        class="save-countdown__duration-bar"
      />
    </transition>

    <div
      v-if="!isCountingDown"
      class="save-countdown__status-bar"
      :class="{
        'save-countdown__status-bar--saving': isSaving,
        'save-countdown__status-bar--failed': failed,
        'save-countdown__status-bar--saved-at-least-once': savedAtLeastOnce }"
    />

    <button
      type="button"
      class="save-countdown__save-button"
      :class="{ 'save-countdown__save-button--showing': isCountingDown }"
      @click="doSave"
    >
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
    rowObject: {
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
      return this.$store.getters[GetterNames.DoesRowObjectNeedCountdown](this.rowObject.id)
    },
    isSaving () {
      return this.rowObject.isSaving
    },
    savedAtLeastOnce () {
      return this.rowObject.hasSavedAtLeastOnce
    }
  },

  watch: {
    needsCountdown (needsCountdown) {
      if (needsCountdown) {
        this.isCountingDown = false
        requestAnimationFrame(_ => {
          this.failed = false
          this.isCountingDown = true
          this.$store.commit(MutationNames.CountdownStartedFor, {
            rowObjectId: this.rowObject.id,
            rowObjectType: this.rowObject.type
          })
        })
      }
    }
  },

  methods: {
    doSave () {
      this.isCountingDown = false
      this.$store.dispatch(ActionNames.SaveObservationsFor, {
        rowObjectId: this.rowObject.id,
        rowObjectType: this.rowObject.type
      }).then(response => {
        if (response.includes(false)) {
          this.failed = true
        }
      })
    }
  }
}
</script>

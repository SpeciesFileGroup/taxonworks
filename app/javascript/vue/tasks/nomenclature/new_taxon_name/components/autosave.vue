<template>
  <div>
    <div class="meter">
      <span
        class="full_width progress-container">
        <transition
          name="meter-animation"
          @after-enter="save">
          <span
            v-if="triggerAutosave && !disabled"
            class="progress"/>
        </transition>
      </span>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'

export default {
  props: {
    disabled: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    lastSave () {
      return this.$store.getters[GetterNames.GetLastSave]
    },
    lastChange () {
      return this.$store.getters[GetterNames.GetLastChange]
    }
  },
  data () {
    return {
      triggerAutosave: false
    }
  },
  watch: {
    lastChange (newVal) {
      if (newVal > this.lastSave) {
        this.restart()
      }
    },
    disabled(newVal) {
      this.restart()
    },
    lastSave (newVal) {
      this.restart()
    }
  },
  methods: {
    save () {
      if (this.disabled) return
      this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon).then(() => {
        this.restart()
      })
    },
    restart () {
      this.triggerAutosave = false
      requestAnimationFrame(_ => {
        this.triggerAutosave = this.lastChange > this.lastSave
      })
    }
  }
}
</script>

<style lang="scss">
.meter {
  height: 1px;
  position: relative;
  background-color: transparent;
  overflow: hidden;
}

.progress-container {
  display: block;
  height: 100%;
}

.progress {
  display: block;
  height: 100%;
  background-color: green;
}

.meter-animation-enter-active {
  animation: progressBar 3s linear;
  animation-fill-mode:both;
}

@keyframes progressBar {
    from {
      width: 0%;
    }

    to {
      width: 100%;
    }
}
</style>

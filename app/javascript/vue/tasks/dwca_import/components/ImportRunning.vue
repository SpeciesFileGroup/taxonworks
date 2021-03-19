<template>
  <div class="import-running-box">
    <transition name="bounce">
      <div
        v-if="settings.isProcessing && !settings.importModalView"
        class="import-running-container panel content">
        <div class="flex-separate middle">
          <div class="horizontal-left-content">
            <div class="import-spinner">
              <spinner-component
                :show-legend="false"/>
            </div>
            <span>Importing rows...</span>
          </div>
          <button
            type="button"
            class="button button-default normal-input margin-medium-right"
            :disabled="settings.stopRequested"
            @click="stopImport">
            Stop import
          </button>
        </div>
      </div>
    </transition>
  </div>
</template>

<script>
import SpinnerComponent from 'components/spinner'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  components: {
    SpinnerComponent
  },

  computed: {
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },

      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    }
  },

  methods: {
    stopImport () {
      this.settings.stopRequested = true
    }
  }
}
</script>
<style lang="scss" scoped>
.import-running-box {
    position: absolute;
    bottom: 20px;
    left: 50%;
    transform: translateX(-50%);
}
  .import-running-container {
    background-color: white;
    width: 400px;
    height: 80px;
    transform-origin: center;

    .import-spinner {
      width: 80px;
      height: 80px;
    }

    .box-spinner {
      box-shadow: none;
    }
  }
</style>

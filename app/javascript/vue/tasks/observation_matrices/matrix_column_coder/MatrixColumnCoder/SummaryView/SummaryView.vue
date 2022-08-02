<template>
  <div
    class="summary-view"
    :class="{
      'summary-view--unsaved': isUnsaved,
      'summary-view--saved-at-least-once': savedAtLeastOnce
    }"
  >
    <SpinnerComponent
      legend="Saving changes..."
      :logo-size="{ width: '50px', height: '50px'}"
      v-if="isSaving"
    />
    <div class="flex-separate middle">
      <div class="horizontal-right-content">
        <h3 class="summary-view__title">
          <span
            class="link cursor-pointer"
            @click="isModalVisible = true"
          >
            {{ index }} <span v-html="rowObject.title" />
          </span>
        </h3>
        <a
          type="button"
          target="_blank"
          class="circle-button btn-row-coder"
          title="Matrix row coder"
          :href="`/tasks/observation_matrices/row_coder/index?observation_matrix_row_id=${rowObject.rowId}`"
        />
        <RadialAnnotator :global-id="rowObject.globalId" />
        <RadialObject :global-id="rowObject.globalId" />
      </div>
      <p>
        <button
          type="button"
          @click="returnTop"
        >
          Top
        </button>
      </p>
    </div>
    <div>
      <slot />
    </div>
    <SaveCountdown :row-object="rowObject" />
  </div>
</template>

<style src="./SummaryView.styl" lang="stylus"></style>

<script>
import { GetterNames } from '../../store/getters/getters'
import SpinnerComponent from 'components/spinner.vue'
import SaveCountdown from '../SaveCountdown/SaveCountdown.vue'
import RadialAnnotator from 'components/radials/annotator/annotator'
import RadialObject from 'components/radials/navigation/radial'

export default {
  name: 'SummaryView',

  components: {
    SaveCountdown,
    RadialAnnotator,
    RadialObject,
    SpinnerComponent
  },

  props: {
    index: {
      type: Number,
      required: true
    },

    rowObject: {
      type: Object,
      required: true
    }
  },

  data: () => ({
    isModalVisible: false
  }),

  computed: {
    isUnsaved () {
      return this.$store.getters[GetterNames.IsRowObjectUnsaved](this.rowObject.id)
    },

    savedAtLeastOnce () {
      return this.rowObject.hasSavedAtLeastOnce
    },

    isSaving () {
      return this.$store.getters[GetterNames.IsRowObjectSaving](this.rowObject.id)
    }
  },

  methods: {
    returnTop () {
      window.scrollTo(0, 0)
    }
  }
}
</script>

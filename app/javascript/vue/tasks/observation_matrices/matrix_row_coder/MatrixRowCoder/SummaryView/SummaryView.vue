<template>
  <div
    class="summary-view" 
    :class="{ 'summary-view--unsaved': isUnsaved, 'summary-view--saved-at-least-once': savedAtLeastOnce }">
    <spinner
      legend="Saving changes..."
      :logo-size="{ width: '50px', height: '50px'}"
      v-if="isSaving"/>
    <h2 class="summary-view__title flex-separate">
      <div class="horizontal-left-content">
        {{ index }} {{ descriptor.title }}
        <radial-annotator :global-id="descriptor.globalId"/>
        <radial-object :global-id="descriptor.globalId"/>
      </div>
      <p>
        <button
          type="button"
          @click="returnTop">Top
        </button>
      </p>
    </h2>
    <div>
      <slot/>
    </div>
    <save-countdown :descriptor="descriptor"/>
  </div>
</template>

<style src="./SummaryView.styl" lang="stylus"></style>

<script>
import { GetterNames } from '../../store/getters/getters'
import Spinner from 'components/spinner.vue'
import saveCountdown from '../SaveCountdown/SaveCountdown.vue'
import RadialAnnotator from 'components/radials/annotator/annotator'
import RadialObject from 'components/radials/navigation/radial'

export default {
  name: 'SummaryView',

  components: {
    saveCountdown,
    RadialAnnotator,
    RadialObject,
    Spinner
  },

  props: ['descriptor', 'index'],

  computed: {
    isUnsaved () {
      return this.$store.getters[GetterNames.IsDescriptorUnsaved](this.$props.descriptor.id)
    },
    savedAtLeastOnce () {
      return this.$props.descriptor.hasSavedAtLeastOnce
    },
    isSaving () {
      return this.$store.getters[GetterNames.IsDescriptorSaving](this.$props.descriptor.id)
    }
  },

  methods: {
    returnTop () {
      window.scrollTo(0, 0)
    }
  }
}
</script>

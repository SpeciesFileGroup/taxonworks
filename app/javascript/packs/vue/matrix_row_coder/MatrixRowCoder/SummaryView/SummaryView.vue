<template>
  <div class="summary-view" :class="{ 'summary-view--unsaved': isUnsaved, 'summary-view--saved-at-least-once': savedAtLeastOnce }">
    <h2 class="summary-view__title flex-separate">
      <div class="horizontal-left-content">
        {{ descriptor.title }}
        <radial-annotator :global-id="descriptor.globalId"/>
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
import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters'

import saveCountdown from '../SaveCountdown/SaveCountdown.vue'
import RadialAnnotator from '../../../components/annotator/annotator'

export default {
  name: 'SummaryView',
  props: ['descriptor'],
  computed: {
    isUnsaved: function () {
      return this.$store.getters[GetterNames.IsDescriptorUnsaved](this.$props.descriptor.id)
    },
    savedAtLeastOnce: function () {
      return this.$props.descriptor.hasSavedAtLeastOnce
    }
  },
  methods: {
    zoomIn: function (event) {
      this.$store.commit(MutationNames.SetDescriptorZoom, {
        descriptorId: this.descriptor.id,
        isZoomed: true
      })
    },
    returnTop: function() {
      window.scrollTo(0, 0)
    }
  },
  components: {
    saveCountdown,
    RadialAnnotator
  }
}
</script>

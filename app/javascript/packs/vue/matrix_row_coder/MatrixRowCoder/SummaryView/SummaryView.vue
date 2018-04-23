<template>
  <div class="summary-view" :class="{ 'summary-view--unsaved': isUnsaved, 'summary-view--saved-at-least-once': savedAtLeastOnce }">
    <h2 class="summary-view__title horizontal-left-content">{{ descriptor.title }}
      <radial-annotator :global-id="descriptor.globalId"/>
    </h2>
    <p>
      <button @click="zoomIn" type="button">Zoom</button>
    </p>
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
    }
  },
  components: {
    saveCountdown,
    RadialAnnotator
  }
}
</script>

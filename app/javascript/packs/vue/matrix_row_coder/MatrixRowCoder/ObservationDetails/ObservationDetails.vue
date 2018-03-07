<template>
  <div class="observation-details">
    <confidence-levels
    :confidences="observation.confidences"/>

    <notes
    :notes="observation.notes"/>

    <depictions
    :depictions="observation.depictions"/>

    <citations
    :citations="observation.citations"/>
  </div>
</template>

<style src="./ObservationDetails.styl" lang="stylus"></style>

<script>
import confidenceLevels from '../ConfidenceLevels/ConfidenceLevels.vue'
import notes from '../Notes/Notes.vue'
import depictions from '../Depictions/Depictions.vue'
import citations from '../Citations/Citations.vue'

export default {
  name: 'ObservationDetails',
  props: ['observation'],
  components: {
    confidenceLevels,
    notes,
    depictions,
    citations
  }
}
</script>

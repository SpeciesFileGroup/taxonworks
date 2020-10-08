<template>
  <div id="vue-interactive-keys">
    <div class="horizontal-left-content">
      <h1 class="task_header">Interactive key <span v-if="observationMatrix">| {{ observationMatrix.observation_matrix.name }}</span></h1>
      <div
        class="horizontal-left-content middle margin-small-left"
        v-if="observationMatrix">
        <span
          v-if="observationMatrix.observation_matrix_citation"
          :title="observationMatrix.observation_matrix_citation.cached">
          {{ observationMatrix.observation_matrix_citation.author }}, {{ observationMatrix.observation_matrix_citation.year }}
        </span>
        <radial-annotator :global-id="observationMatrix.observation_matrix.global_id"/>
        <radial-navigation :global-id="observationMatrix.observation_matrix.global_id"/>
      </div>
    </div>

    <menu-bar/>
    <div class="i3 full-height">
      <spinner-component
        v-if="isLoading"
        legend="Loading interactive key..." />
      <div
        class="i3-grid full-height"
        :class="gridLayout">
        <descriptors-view
          class="descriptors-view grid-item content"/>
        <remaining-component class="taxa-remaining grid-item content"/>
        <eliminated-component class="taxa-eliminated grid-item content"/>
      </div>
    </div>
  </div>
</template>

<script>
import RadialAnnotator from 'components/radials/annotator/annotator'
import RadialNavigation from 'components/radials/navigation/radial'
import RemainingComponent from './components/Remaining'
import EliminatedComponent from './components/Eliminated'
import DescriptorsView from './components/DescriptorsView'
import { ActionNames } from './store/actions/actions'
import MenuBar from './components/MenuBar'
import { GetterNames } from './store/getters/getters'
import SpinnerComponent from 'components/spinner'

export default {
  components: {
    DescriptorsView,
    RemainingComponent,
    EliminatedComponent,
    SpinnerComponent,
    MenuBar,
    RadialNavigation,
    RadialAnnotator
  },
  computed: {
    gridLayout () {
      return this.$store.getters[GetterNames.GetSettings].gridLayout
    },
    isLoading () {
      return this.$store.getters[GetterNames.GetSettings].isLoading
    },
    observationMatrix () {
      return this.$store.getters[GetterNames.GetObservationMatrix]
    }
  },
  mounted () {
    const urlParams = new URLSearchParams(window.location.search)
    const matrixId = urlParams.get('observation_matrix_id')

    if (/^\d+$/.test(matrixId)) {
      this.$store.dispatch(ActionNames.LoadObservationMatrix, matrixId)
    }
  }
}
</script>

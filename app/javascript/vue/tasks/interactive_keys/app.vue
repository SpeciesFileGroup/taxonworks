<template>
  <div id="vue-interactive-keys">
    <h1 class="task_header">Interactive key</h1>
    <menu-bar/>
    <div class="i3 full-height">
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
import RemainingComponent from './components/Remaining'
import EliminatedComponent from './components/Eliminated'
import DescriptorsView from './components/DescriptorsView'
import { ActionNames } from './store/actions/actions'
import MenuBar from './components/MenuBar'
import { GetterNames } from './store/getters/getters'

export default {
  components: {
    DescriptorsView,
    RemainingComponent,
    EliminatedComponent,
    MenuBar
  },
  computed: {
    gridLayout () {
      return this.$store.getters[GetterNames.GetSettings].gridLayout
    }
  },
  data () {
    return {
      observationMatrix: undefined
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

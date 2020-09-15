<template>
  <nav-component>
    <div class="flex-separate">
      <div>
        <span v-if="observationMatrix">{{ observationMatrix.object_tag }}</span>
        <autocomplete
          v-else
          url="/observation_matrices/autocomplete"
          param="term"
          label="label_html"
          placeholder="Search a observation matrix"
          @getItem="loadMatrix"
        />
      </div>
      <div class="middle">
        <button
          v-for="layout in layouts"
          type="button"
          :key="layout"
          :value="layout"
          @click="setLayout(layout)"
          class="button normal-input button-default margin-small-left"
          :class="layout">
          <div class="i3-grid layout-mode-1 grid-icon">
            <div class="descriptors-view grid-item"/>
            <div class="taxa-remaining grid-item"/>
            <div class="taxa-eliminated grid-item"/>
          </div>
        </button>
      </div>
    </div>
  </nav-component>
</template>

<script>

import NavComponent from 'components/navBar'
import Autocomplete from 'components/autocomplete'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'

export default {
  components: {
    NavComponent,
    Autocomplete
  },
  computed: {
    observationMatrix () {
      return this.$store.getters[GetterNames.GetObservationMatrix]
    },
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    }
  },
  data () {
    return {
      layouts: ['layout-mode-1 ', 'layout-mode-2']
    }
  },
  methods: {
    setLayout (layout) {
      this.settings.gridLayout = layout
    },
    loadMatrix (matrix) {
      this.$store.dispatch(ActionNames.LoadObservationMatrix, matrix.id)
    }
  }
}
</script>

<style>
</style>

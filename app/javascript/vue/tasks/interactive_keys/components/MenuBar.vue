<template>
  <nav-component>
    <div class="flex-separate">
      <div>
        <autocomplete
          url="/observation_matrices/autocomplete"
          param="term"
          label="label_html"
          placeholder="Search a observation matrix"
          clear-after
          @getItem="loadMatrix($event.id)"
        />
      </div>
      <div class="horizontal-left-content">
        <error-tolerance class="margin-small-right"/>
        <identifier-rank class="margin-small-right"/>
        <language-component class="margin-small-right"/>
        <sorting-component/>
      </div>
      <div class="horizontal-left-content">
        <button
          type="button"
          class="button normal-input button-default margin-small-right"
          @click="resetView">
          Reset
        </button>
        <button
          v-if="observationMatrix"
          type="button"
          class="button normal-input button-default"
          @click="loadMatrix(observationMatrix.observation_matrix_id)">
          Proceed
        </button>
        <div class="middle">
          <button
            type="button"
            @click="setLayout(settings.gridLayout)"
            class="button normal-input button-default margin-small-left"
            :class="layouts[settings.gridLayout]">
            <div class="i3-grid layout-mode-1 grid-icon">
              <div class="descriptors-view grid-item"/>
              <div class="taxa-remaining grid-item"/>
              <div class="taxa-eliminated grid-item"/>
            </div>
          </button>
        </div>
      </div>
    </div>
  </nav-component>
</template>

<script>

import NavComponent from 'components/navBar'
import Autocomplete from 'components/autocomplete'
import SetParam from 'helpers/setParam'
import SortingComponent from './Filters/Sorting.vue'
import IdentifierRank from './Filters/IdentifierRank'
import ErrorTolerance from './Filters/ErrorTolerance'
import LanguageComponent from './Filters/Language'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'

export default {
  components: {
    NavComponent,
    Autocomplete,
    IdentifierRank,
    ErrorTolerance,
    LanguageComponent,
    SortingComponent
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
      layouts: {
        'layout-mode-1': 'layout-mode-2',
        'layout-mode-2': 'layout-mode-1'
      }
    }
  },
  methods: {
    setLayout (layout) {
      this.settings.gridLayout = this.layouts[layout]
    },
    loadMatrix (id) {
      if (!this.observationMatrix || id !== this.observationMatrix.observation_matrix_id) {
        SetParam('/tasks/observation_matrices/interactive_key', 'observation_matrix_id', 24)
      }
      this.$store.dispatch(ActionNames.LoadObservationMatrix, id)
    },
    resetView () {
      this.$store.commit(MutationNames.SetDescriptorsFilter, {})
      this.$store.dispatch(ActionNames.LoadObservationMatrix, this.observationMatrix.observation_matrix_id)
    }
  }
}
</script>

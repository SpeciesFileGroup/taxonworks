<template>
  <nav-component>
    <div class="flex-separate">
      <div>
        <span v-if="observationMatrix">{{ observationMatrix.observation_matrix.name }}</span>
        <autocomplete
          v-else
          url="/observation_matrices/autocomplete"
          param="term"
          label="label_html"
          placeholder="Search a observation matrix"
          @getItem="loadMatrix($event.id)"
        />
      </div>
      <div class="horizontal-left-content">
        <button
          v-if="observationMatrix"
          type="button"
          class="button normal-input button-default"
          @click="loadMatrix(observationMatrix.observation_matrix_id)">
          Process
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
      this.$store.dispatch(ActionNames.LoadObservationMatrix, id)
    }
  }
}
</script>

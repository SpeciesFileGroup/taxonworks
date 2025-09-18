<template>
  <nav-component>
    <div class="flex-separate middle">
      <autocomplete
        url="/observation_matrices/autocomplete"
        param="term"
        label="label_html"
        placeholder="Search a observation matrix"
        clear-after
        @getItem="loadMatrix($event.id)"
      />
      <ul class="context-menu">
        <li>
          <refresh-component />
        </li>
        <li>
          <eliminate-unknowns />
        </li>
        <li>
          <error-tolerance />
        </li>
        <li>
          <identifier-rank v-model="filters.identified_to_rank" />
        </li>
        <li v-if="existLanguages">
          <language-component
            :language-list="observationMatrix.descriptor_available_languages"
            v-model="filters.language_id"
          />
        </li>
        <li>
          <sorting-component />
        </li>
        <li v-if="existKeywords">
          <keywords-component />
        </li>
      </ul>
      <div class="horizontal-left-content">
        <div class="middle margin-small-right">
          <button
            v-if="showSendToKeyButton"
            type="button"
            @click="sendToKey"
            class="button normal-input button-default margin-small-left"
          >
            Return to key
          </button>
          <button
            type="button"
            @click="setLayout(settings.gridLayout)"
            class="button normal-input button-default margin-small-left"
            :class="layouts[settings.gridLayout]"
          >
            <div class="i3-grid layout-mode-1 grid-icon">
              <div class="descriptors-view grid-item" />
              <div class="taxa-remaining grid-item" />
              <div class="taxa-eliminated grid-item" />
            </div>
          </button>
        </div>
        <button
          type="button"
          class="button normal-input button-default margin-small-right"
          @click="resetView"
        >
          Reset
        </button>
        <button
          v-if="observationMatrix"
          type="button"
          class="button normal-input button-default"
          @click="proceed(observationMatrix.observation_matrix_id)"
        >
          Refresh
        </button>
      </div>
    </div>
  </nav-component>
</template>

<script>
import NavComponent from '@/components/layout/NavBar'
import Autocomplete from '@/components/ui/Autocomplete'
import SetParam from '@/helpers/setParam'
import SortingComponent from './Filters/Sorting.vue'
import IdentifierRank from './Filters/IdentifierRank'
import ErrorTolerance from './Filters/ErrorTolerance'
import LanguageComponent from './Filters/Language'
import EliminateUnknowns from './Filters/EliminateUnknowns'
import RefreshComponent from './Filters/Refresh'
import KeywordsComponent from './Filters/Keywords'
import scrollToTop from '../utils/scrollToTop.js'
import { RouteNames } from '@/routes/routes'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'
import sides from '../const/filterings'

export default {
  components: {
    NavComponent,
    Autocomplete,
    IdentifierRank,
    EliminateUnknowns,
    ErrorTolerance,
    KeywordsComponent,
    LanguageComponent,
    SortingComponent,
    RefreshComponent
  },

  computed: {
    observationMatrix() {
      return this.$store.getters[GetterNames.GetObservationMatrix]
    },

    existLanguages() {
      return !!this.observationMatrix?.descriptor_available_languages?.length
    },

    existKeywords() {
      return !!this.observationMatrix?.descriptor_available_keywords?.length
    },

    showSendToKeyButton() {
      if (!!this.$store.getters[GetterNames.GetLeadId] &&
          !!this.$store.getters[GetterNames.GetFilter] &&
          this.$store.getters[GetterNames.GetObservationMatrix]?.observation_matrix_id) {
        return true
      } else {
        return false
      }
    },

    settings: {
      get() {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set(value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    },

    filters: {
      get() {
        return this.$store.getters[GetterNames.GetParamsFilter]
      },
      set(value) {
        this.$store.commit(MutationNames.SetParamsFilter, value)
      }
    }
  },

  data() {
    return {
      layouts: {
        'layout-mode-1': 'layout-mode-2',
        'layout-mode-2': 'layout-mode-1'
      }
    }
  },

  methods: {
    setLayout(layout) {
      this.settings.gridLayout = this.layouts[layout]
    },

    loadMatrix(id) {
      if (
        !this.observationMatrix ||
        id !== this.observationMatrix?.observation_matrix_id
      ) {
        SetParam(
          '/tasks/observation_matrices/interactive_key',
          'observation_matrix_id',
          id
        )
      }
      this.$store.commit(MutationNames.SetObservationMatrix, undefined)
      this.$store.commit(MutationNames.SetDescriptorsFilter, {})
      this.$store.dispatch(ActionNames.LoadObservationMatrix, id)
      scrollToTop()
    },

    proceed(id) {
      this.$store.dispatch(ActionNames.LoadObservationMatrix, id)
      scrollToTop()
    },

    resetView() {
      this.$store.commit(MutationNames.SetDescriptorsFilter, {})
      this.$store.commit(MutationNames.SetRowFilter, [])
      this.$store.dispatch(
        ActionNames.LoadObservationMatrix,
        this.observationMatrix.observation_matrix_id
      )
      scrollToTop()
    },

    sendToKey() {
      const leadId = this.$store.getters[GetterNames.GetLeadId]

      const selectedDescriptorStates = this.$store.getters[GetterNames.GetSelectedDescriptorStates]
      sessionStorage.setItem('interactive_key_to_key_descriptor_data', JSON.stringify(selectedDescriptorStates))

      let otuIds = {}
      if (selectedDescriptorStates.length > 0) {
        otuIds = this.$store.getters[GetterNames.GetObservationObjectIdsByType]([sides.Remaining, sides.Both], 'Otu')
      }
      sessionStorage.setItem('interactive_key_to_key_otu_ids', JSON.stringify(otuIds))

      window.location.href = `${RouteNames.NewLead}?lead_id=${leadId}`
    }

  }
}
</script>

<template>
  <nav-component>
    <div class="flex-separate middle">
      <div
        class="horizontal-left-content gap-small middle"
        v-if="leadId"
      >
        <VIcon
          name="attention"
          color="attention"
          small
        />
        <span>The task is being used in service of a key</span>
      </div>
      <autocomplete
        v-else
        url="/observation_matrices/autocomplete"
        param="term"
        label="label_html"
        placeholder="Search an observation matrix"
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
          <div
            v-if="showSendToKeyButton"
            class="key-return-panel horizontal-left-content gap-small margin-small-left"
          >
            <button
              type="button"
              @click="sendToKey"
              class="button normal-input button-default"
            >
              Return to key
            </button>
            <label class="horizontal-left-content gap-xsmall">
              <input
                type="checkbox"
                v-model="settings.sendCharacterDepictions"
                @change="persistSendDepictions"
              />
              <span>Send character depictions</span>
            </label>
          </div>
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
          v-if="!leadId"
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
import VIcon from '@/components/ui/VIcon/index.vue'
import { RouteNames } from '@/routes/routes'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'
import sides from '../const/filterings'
import { GetCharacterStateDepictions } from '../request/resources'

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
    RefreshComponent,
    VIcon
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

    leadId() {
      return this.$store.getters[GetterNames.GetLeadId]
    },

    showSendToKeyButton() {
      if (
        !!this.leadId &&
        !!this.$store.getters[GetterNames.GetFilter] &&
        this.$store.getters[GetterNames.GetObservationMatrix]
          ?.observation_matrix_id
      ) {
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

    async sendToKey() {
      const selectedDescriptorStates =
        this.$store.getters[GetterNames.GetSelectedDescriptorStates]
      sessionStorage.setItem(
        'interactive_key_to_key_descriptor_data',
        JSON.stringify(selectedDescriptorStates)
      )

      let otuIds = {}
      if (selectedDescriptorStates.length > 0) {
        otuIds = this.$store.getters[GetterNames.GetObservationObjectIdsByType](
          [sides.Remaining, sides.EliminatedForKey],
          'Otu'
        )
      }
      sessionStorage.setItem(
        'interactive_key_to_key_otu_ids',
        JSON.stringify(otuIds)
      )

      if (this.settings.sendCharacterDepictions) {
        const imageIds = await this.collectSelectedDepictionImageIds()
        sessionStorage.setItem(
          'interactive_key_to_key_depiction_image_ids',
          JSON.stringify(imageIds)
        )
      } else {
        sessionStorage.setItem(
          'interactive_key_to_key_depiction_image_ids',
          JSON.stringify([])
        )
      }

      window.location.href = `${RouteNames.NewLead}?lead_id=${this.leadId}`
    },

    persistSendDepictions() {
      sessionStorage.setItem(
        'interactive_key_send_character_depictions',
        this.settings.sendCharacterDepictions
      )
    },

    selectedCharacterStateIds() {
      if (!this.observationMatrix) {
        return []
      }
      const selected = this.observationMatrix.selected_descriptors_hash || {}
      const ids = this.observationMatrix.list_of_descriptors
        .filter(
          (descriptor) =>
            descriptor.status === 'used' &&
            // Only qualitative character states can have depictions.
            descriptor.type === 'Descriptor::Qualitative'
        )
        .flatMap((descriptor) => selected[descriptor.id] || [])
      return [...new Set(ids)]
    },

    async collectSelectedDepictionImageIds() {
      const characterStateIds = this.selectedCharacterStateIds()
      if (characterStateIds.length === 0) {
        return []
      }
      const depictions = await Promise.all(
        characterStateIds.map((id) =>
          GetCharacterStateDepictions(id)
            .then((response) => response.body)
            .catch(() => [])
        )
      )
      const imageIds = depictions
        .flat()
        .map((depiction) => depiction.image_id || depiction.image?.id)
        .filter((id) => id)
      return [...new Set(imageIds)]
    }
  }
}
</script>

<style scoped>
.key-return-panel {
  padding: 6px 10px;
  border: 1px solid var(--border-color);
  border-radius: 8px;
  background-color: var(--panel-bg-color);
}
</style>

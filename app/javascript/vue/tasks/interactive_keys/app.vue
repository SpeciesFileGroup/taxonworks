<template>
  <div id="vue-interactive-keys">
    <div class="flex-separate">
      <h1 class="task_header">
        <span
          v-if="observationMatrix"
          v-text="observationMatrix.observation_matrix.name"
        />
      </h1>
      <div
        class="horizontal-left-content middle margin-small-left gap-small"
        v-if="observationMatrix"
      >
        <span
          v-if="observationMatrix.observation_matrix_citation"
          :title="
            parseString(observationMatrix.observation_matrix_citation.cached)
          "
        >
          {{
            observationMatrix.observation_matrix_citation.cached_author_string
          }}, {{ observationMatrix.observation_matrix_citation.year }}
        </span>
        <radial-annotator
          :global-id="observationMatrix.observation_matrix.global_id"
        />
        <radial-navigation
          :global-id="observationMatrix.observation_matrix.global_id"
        />
      </div>
    </div>

    <menu-bar />
    <div class="i3 full-height">
      <spinner-component
        v-if="isLoading"
        legend="Loading interactive key..."
      />
      <div
        class="i3-grid full-height"
        :class="gridLayout"
      >
        <descriptors-view class="descriptors-view grid-item content" />
        <remaining-component class="taxa-remaining grid-item content" />
        <eliminated-component class="taxa-eliminated grid-item content" />
      </div>
    </div>
  </div>
</template>

<script>
import RadialAnnotator from '@/components/radials/annotator/annotator'
import RadialNavigation from '@/components/radials/navigation/radial'
import RemainingComponent from './components/Remaining.vue'
import EliminatedComponent from './components/Eliminated.vue'
import DescriptorsView from './components/DescriptorsView.vue'
import { ActionNames } from './store/actions/actions'
import MenuBar from './components/MenuBar.vue'
import { GetterNames } from './store/getters/getters'
import SpinnerComponent from '@/components/ui/VSpinner'
import { MutationNames } from './store/mutations/mutations'
import { useParamsSessionPop } from '@/composables/useParamsSessionPop'

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
    gridLayout() {
      return this.$store.getters[GetterNames.GetSettings].gridLayout
    },
    isLoading() {
      return this.$store.getters[GetterNames.GetSettings].isLoading
    },
    observationMatrix() {
      return this.$store.getters[GetterNames.GetObservationMatrix]
    },
    settings: {
      get() {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set(value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    }
  },

  data() {
    return {
      countToRefreshMode: 250
    }
  },

  created() {
    const { matrixId, leadId, otuIds } = useParamsSessionPop(
      {
        observation_matrix_id: 'matrixId',
        lead_id: 'leadId',
        otu_ids: 'otuIds'
      },
      'key_to_interactive_key'
    )
    const sendDepictions =
      sessionStorage.getItem('interactive_key_send_character_depictions')
    if (sendDepictions !== null) {
      this.settings.sendCharacterDepictions = sendDepictions === 'true'
    }

    if (otuIds) {
      this.$store.commit(MutationNames.SetParamsFilter, {
        ...this.$store.getters[GetterNames.GetFilter],
        otu_filter: otuIds
      })
    }
    if (/^\d+$/.test(matrixId)) {
      this.$store
        .dispatch(ActionNames.LoadObservationMatrix, matrixId)
        .then(() => {
          this.settings.refreshOnlyTaxa =
            this.observationMatrix.remaining.length >= this.countToRefreshMode
        })
    }
    if (leadId) {
      this.$store.commit(MutationNames.SetLeadId, leadId)
    }
  },
  methods: {
    parseString(string) {
      return string.replace(/<\/?[^>]+(>|$)/g, '')
    }
  }
}
</script>

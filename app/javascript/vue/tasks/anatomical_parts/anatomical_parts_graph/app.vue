<template>
  <div>
    <div class="flex-separate gap-medium">
      <h1>Anatomical parts graph</h1>
      <div class="flex-separate">
        <div class="horizontal-left-content gap-small">
          <VBtn
            v-if="graph"
            color="primary"
            circle
            medium
            title="Download graph as SVG"
            @click="() => graph.downloadAsSvg()"
          >
            <VIcon
              name="download"
              x-small
              title="Download graph as SVG"
            />
          </VBtn>

          <VBtn
            color="primary"
            circle
            medium
            title="Reset"
            @click="reset"
          >
            <VIcon
              name="reset"
              x-small
              title="Reset"
            />
          </VBtn>
        </div>
      </div>
    </div>
    <div class="horizontal-left-content align-start gap-medium">
      <div class="search-column">
        <div class="panel content margin-large-bottom">
          <h3>Anatomical part</h3>
          <SmartSelector
            ref="anatomicalPartSelector"
            v-model="selectedAnatomicalPart"
            model="anatomical_parts"
            pin-section="AnatomicalParts"
            pin-type="AnatomicalPart"
            auto-focus
            @selected="({ id }) => {
              const newParam = { anatomical_part_id: id }
              resetFrom(RESET_SOURCE.ANATOMICAL_PART, newParam)
              createGraph(newParam)
            }"
          />
          <SmartSelectorItem
            :item="selectedAnatomicalPart"
            label="object_label"
            @unset="() => {
              selectedAnatomicalPart = null
              reset()
            }"
          />
        </div>

        <div class="panel content margin-large-bottom">
          <h3>Origins</h3>
          <VSwitch
            class="separate-bottom"
            v-model="originsSwitch"
            use-index
            :options="ORIGIN_SWITCH_OPTIONS"
          />
          <SmartSelector
            v-if="originsSwitch"
            v-model="selectedOrigin"
            :model="originsSwitch"
            :pin-section="ORIGIN_SWITCH_OPTIONS[originsSwitch] + 's'"
            :pin-type="ORIGIN_SWITCH_OPTIONS[originsSwitch]"
            @selected="({ id }) => {
              const newParam = {
                [ID_PARAM_FOR[ORIGIN_SWITCH_OPTIONS[originsSwitch]]]: id
              }
              resetFrom(RESET_SOURCE.ORIGIN, newParam)
              createGraph(newParam)
            }"
          />
          <SmartSelectorItem
            :item="selectedOrigin"
            label="object_label"
            @unset="() => {
              selectedOrigin = null
              reset()
            }"
          />
        </div>

        <div class="panel content margin-large-bottom">
          <h3>Endpoints</h3>
          <VSwitch
            class="separate-bottom"
            v-model="endpointsSwitch"
            use-index
            :options="ENDPOINT_SWITCH_OPTIONS"
          />
          <SmartSelector
            v-if="endpointsSwitch"
            v-model="selectedEndpoint"
            :model="endpointsSwitch"
            :pin-section="ORIGIN_SWITCH_OPTIONS[originsSwitch] + 's'"
            :pin-type="ORIGIN_SWITCH_OPTIONS[originsSwitch]"
            @selected="({ id }) => {
              const newParam = {
                [ID_PARAM_FOR[ENDPOINT_SWITCH_OPTIONS[endpointsSwitch]]]: id
              }
              resetFrom(RESET_SOURCE.ENDPOINT, newParam)
              createGraph(newParam)
            }"
          />
          <SmartSelectorItem
            :item="selectedEndpoint"
            label="object_label"
            @unset="() => {
              selectedEndpoint = null
              reset()
            }"
          />
        </div>
      </div>

      <AnatomicalPartsGraph
        ref="graph"
        @update-graph="updateGraph"
      />
    </div>
  </div>
</template>

<script setup>
import AnatomicalPartsGraph from './components/AnatomicalPartsGraph.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import platformKey from '@/helpers/getPlatformKey'
import { URLParamsToJSON } from '@/helpers/url/parse'
import { onMounted, ref } from 'vue'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams'
import {
  ANATOMICAL_PART,
  COLLECTION_OBJECT,
  EXTRACT,
  FIELD_OCCURRENCE,
  OTU,
  SEQUENCE,
  SOUND
} from '@/constants'
import { useHotkey } from '@/composables'
import { usePopstateListener } from '@/composables'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VSwitch from '@/components/ui/VSwitch.vue'
import qs from 'qs'

const ORIGIN_SWITCH_OPTIONS = {
  collection_objects: COLLECTION_OBJECT,
  field_occurrences: FIELD_OCCURRENCE,
  otus: OTU
}

const ENDPOINT_SWITCH_OPTIONS = {
  extracts: EXTRACT,
  sequences: SEQUENCE,
  sounds: SOUND
}

const RESET_SOURCE = {
  ANATOMICAL_PART: 'anatomical part',
  ORIGIN: 'origin',
  ENDPOINT: 'endpoint'
}

const graph = ref()
const anatomicalPartSelector = ref()
const originsSwitch = ref()
const endpointsSwitch = ref()
const selectedAnatomicalPart = ref()
const selectedOrigin = ref()
const selectedEndpoint = ref()

useHotkey([
  {
    keys: [platformKey(), 'r'],
    preventDefault: true,
    handler() {
      graph.value.resetStore()
    }
  }
])

onMounted(() => {
  processParams()

  TW.workbench.keyboard.createLegend(
    `${platformKey()}+r`,
    'Reset',
    'Anatomical parts graph'
  )
})

function createGraph(idsHash) {
  if (!Object.values(idsHash).some((v) => !!v)) {
    return
  }

  graph.value.resetStore()
  graph.value.createGraph(idsHash)
}

function updateGraph() {
  const { parameter, id } = queryParam()
  if (id) {
    graph.value.createGraph({ [parameter]: id })
  }
}

function processParams() {
  const { parameter, id } = queryParam()
  if (id) {
    graph.value.createGraph({ [parameter]: id })
    return true
  }

  return false
}

function queryParam() {
  // Order matters.
  const idKeys = [
    ID_PARAM_FOR[ANATOMICAL_PART],
    ID_PARAM_FOR[COLLECTION_OBJECT],
    ID_PARAM_FOR[FIELD_OCCURRENCE],
    ID_PARAM_FOR[OTU],
    ID_PARAM_FOR[EXTRACT],
    ID_PARAM_FOR[SEQUENCE],
    ID_PARAM_FOR[SOUND]
  ]
  const params = URLParamsToJSON(location.href)
  const firstMatch = idKeys.find((k) => !!params[k])
  if (firstMatch) {
    return {
      parameter: firstMatch,
      id: params[firstMatch]
    }
  } else {
    return {
      parameter: null,
      id: null
    }
  }
}

usePopstateListener(() => {
  if (!processParams()) {
    resetFrom(null)
  }
})

function resetFrom(source, newParam = null) {
  graph.value.resetStore()

  if (source == RESET_SOURCE.ANATOMICAL_PART) {
    selectedOrigin.value = null
    selectedEndpoint.value = null
  } else if (source == RESET_SOURCE.ORIGIN) {
    selectedAnatomicalPart.value = null
    selectedEndpoint.value = null
  } else if (source == RESET_SOURCE.ENDPOINT) {
    selectedAnatomicalPart.value = null
    selectedOrigin.value = null
  } else {
    anatomicalPartSelector.value.refresh(true)
    originsSwitch.value = null
    endpointsSwitch.value = null

    selectedAnatomicalPart.value = null
    selectedOrigin.value = null
    selectedEndpoint.value = null
  }

  if (!!newParam) {
    const urlParams = qs.stringify(newParam, { arrayFormat: 'brackets' })
    history.pushState(null, null, `${window.location.pathname}?${urlParams}`)
  }
}

function reset() {
  resetFrom(null)
}
</script>

<style scoped>
.graph-section {
  position: relative;
}

.search-column {
  width: 400px;
}
</style>

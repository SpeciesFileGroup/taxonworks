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
            @click="() => graph.downloadAsSvg()"
          >
            <VIcon
              name="download"
              x-small
            />
          </VBtn>

          <VBtn
            color="primary"
            circle
            medium
            @click="reset"
          >
            <VIcon
              name="reset"
              x-small
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
            model="anatomical_parts"
            auto-focus
            @selected="({ id }) => createGraph({anatomical_part_id: id})"
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
            :model="originsSwitch"
            @selected="({ id }) => createGraph({
              [ID_PARAM_FOR[ORIGIN_SWITCH_OPTIONS[originsSwitch]]]: id
            })"
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
            :model="endpointsSwitch"
            @selected="({ id }) => createGraph({
              [ID_PARAM_FOR[ENDPOINT_SWITCH_OPTIONS[endpointsSwitch]]]: id
            })"
          />
        </div>
      </div>

      <AnatomicalPartsGraph ref="graph" />
    </div>
  </div>
</template>

<script setup>
import AnatomicalPartsGraph from './components/AnatomicalPartsGraph.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import setParam from '@/helpers/setParam.js'
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
import { RouteNames } from '@/routes/routes.js'
import { useHotkey } from '@/composables'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import VSwitch from '@/components/ui/VSwitch.vue'

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

const graph = ref()
const anatomicalPartSelector = ref()
const originsSwitch = ref()
const endpointsSwitch = ref()

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
    createGraph({ [firstMatch]: params[firstMatch] })
  }

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

function reset() {
  graph.value.resetStore()

  anatomicalPartSelector.value.refresh(true)
  originsSwitch.value = null
  endpointsSwitch.value = null

  // TODO: do this better?
  setParam(RouteNames.AnatomicalPartsGraph, ID_PARAM_FOR[ANATOMICAL_PART])
  setParam(RouteNames.AnatomicalPartsGraph, ID_PARAM_FOR[COLLECTION_OBJECT])
  setParam(RouteNames.AnatomicalPartsGraph, ID_PARAM_FOR[FIELD_OCCURRENCE])
  setParam(RouteNames.AnatomicalPartsGraph, ID_PARAM_FOR[OTU])
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

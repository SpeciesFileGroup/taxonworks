<template>
  <div>
    <h1>Anatomical parts graph</h1>
    <AnatomicalPartsGraph ref="graph">
      <template #header="{ isGraphUnsaved, edges, currentGraph}">
        <VNavbar>
          <div class="flex-separate">
            <div class="horizontal-left-content middle">
              <VAutocomplete
                url="/anatomical_parts/autocomplete"
                param="term"
                label="label_html"
                autofocus
                clear-after
                placeholder="Search for a part or an origin"
                @get-item="
                  ({ id }) => {
                    loadGraph(id)
                  }
                "
              />
              <template v-if="currentGraph.id">
                <div
                  class="horizontal-left-content margin-small-left gap-small"
                >
                  <VBtn
                    color="primary"
                    circle
                    @click="() => graph.openGraphModal()"
                  >
                    <VIcon
                      name="pencil"
                      x-small
                    />
                  </VBtn>
                  <RadialObject :global-id="currentGraph.globalId" />
                  <RadialAnnotator :global-id="currentGraph.globalId" />
                  <RadialNavigator :global-id="currentGraph.globalId" />
                </div>
                <span class="margin-small-left">
                  {{ currentGraph.name || currentGraph.label }}
                </span>
              </template>
            </div>
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
        </VNavbar>
      </template>
    </AnatomicalPartsGraph>
  </div>
</template>

<script setup>
import AnatomicalPartsGraph from './components/AnatomicalPartsGraph.vue'
import VNavbar from '@/components/layout/NavBar'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import setParam from '@/helpers/setParam.js'
import platformKey from '@/helpers/getPlatformKey'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
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

const graph = ref()

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
  const ids = idKeys.map((id_key) => params[id_key])

  // for (let i = 0; i < ids.length; i++) {
  //   if (ids[i]) {
  //     // Null all parameters after the first one that's set.
  //     for (let j = i; j <= ids.length; j++) {
  //       // TODO
  //       //setParam(RouteNames.AnatomicalPartsGraph, idKeys[j])
  //       ids[j] = undefined
  //     }
  //   }
  // }
  createGraph(
    Object.fromEntries(idKeys.map((k, i) => [k, ids[i]]))
  )

  TW.workbench.keyboard.createLegend(
    `${platformKey()}+r`,
    'Reset',
    'Anatomical parts graph'
  )
})

function createGraph(idsHash) {
  graph.value.resetStore()
  graph.value.createGraph(idsHash)
}

function reset() {
  graph.value.resetStore()

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
</style>

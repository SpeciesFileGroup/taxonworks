<template>
  <div>
    <h1>Biological associations graph</h1>
    <BiologicalAssociationGraph ref="graph">
      <template #header="{ isGraphUnsaved, edges, currentGraph, sourceIds }">
        <VNavbar>
          <div class="flex-separate">
            <div class="horizontal-left-content middle">
              <VAutocomplete
                url="/biological_associations_graphs/autocomplete"
                param="term"
                label="label_html"
                autofocus
                clear-after
                placeholder="Search a graph..."
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
                  <RadialAnnotator :global-id="currentGraph.globalId" />
                </div>
                <span>{{ currentGraph.name || currentGraph.label }}</span>
              </template>
            </div>
            <div class="horizontal-left-content gap-small">
              <VIcon
                v-if="isGraphUnsaved"
                name="attention"
                small
                color="attention"
                title="You have unsaved changes."
              />
              <VBtn
                color="create"
                medium
                :disabled="!Object.keys(edges || {}).length"
                @click="saveGraph"
              >
                Save
              </VBtn>
              <VBtn
                color="primary"
                medium
                :disabled="!sourceIds.length"
                @click="() => graph.openSourceModal()"
              >
                Sources
              </VBtn>
              <VBtn
                v-if="graph"
                color="primary"
                medium
                :disabled="!graph.getBiologicalRelationships().value.length"
                @click="() => (showModalRelated = true)"
              >
                Related
              </VBtn>

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
            <ModalRelated
              v-if="showModalRelated"
              :current-graph="currentGraph"
              :relations="
                [].concat(
                  ...graph
                    .getBiologicalRelationships()
                    .value.map((ba) => [ba.object, ba.subject])
                )
              "
              @add:biological-associations="
                (ids) => {
                  addBiologicalAssociationsToGraph(ids)
                  showModalRelated = false
                }
              "
              @select:graph="
                ($event) => {
                  loadGraph($event.id)
                  showModalRelated = false
                }
              "
              @close="() => (showModalRelated = false)"
            />
          </div>
        </VNavbar>
      </template>
    </BiologicalAssociationGraph>
  </div>
</template>

<script setup>
import BiologicalAssociationGraph from './components/BiologicalAssociationGraph.vue'
import VNavbar from '@/components/layout/NavBar'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import setParam from '@/helpers/setParam.js'
import { useHotkey } from '@/composables'
import platformKey from '@/helpers/getPlatformKey'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import ModalRelated from './components/ModalRelated.vue'
import { URLParamsToJSON } from '@/helpers/url/parse'
import { onMounted, ref } from 'vue'
import { CollectionObject, FieldOccurrence, Otu } from '@/routes/endpoints'
import { RouteNames } from '@/routes/routes.js'

const graph = ref()
const hotkeys = ref([
  {
    keys: [platformKey(), 's'],
    preventDefault: true,
    handler() {
      if (graph.value.isGraphUnsaved) {
        saveGraph()
      }
    }
  },
  {
    keys: [platformKey(), 'r'],
    preventDefault: true,
    handler() {
      graph.value.resetStore()
    }
  },
  {
    keys: [platformKey(), 'a'],
    preventDefault: true,
    handler() {
      if (graph.value.currentNodes.length === 2) {
        graph.value.openEdgeModal()
      } else {
        TW.workbench.alert.create(
          'Select two nodes to create a biological association'
        )
      }
    }
  }
])

const stop = useHotkey(hotkeys.value)
const showModalRelated = ref(false)

onMounted(() => {
  const params = URLParamsToJSON(location.href)
  const biologicalAssociationGraphId = params.biological_associations_graph_id
  const coId = params.collection_object_id
  const foId = params.field_occurrence_id
  const otuId = params.otu_id
  const baId = params.biological_association_id

  if (biologicalAssociationGraphId) {
    loadGraph(biologicalAssociationGraphId)
  }

  if (coId) {
    CollectionObject.find(coId)
      .then(({ body }) => {
        graph.value.addNodeObject(body)
      })
      .catch(() => {})
  }

  if (foId) {
    FieldOccurrence.find(foId)
      .then(({ body }) => {
        graph.value.addNodeObject(body)
      })
      .catch(() => {})
  }

  if (otuId) {
    Otu.find(otuId)
      .then(({ body }) => {
        graph.value.addNodeObject(body)
      })
      .catch(() => {})
  }

  if (baId) {
    graph.value.loadBiologicalAssociations([baId])
  }

  TW.workbench.keyboard.createLegend(
    `${platformKey()}+a`,
    'Create biological association between two nodes',
    'Biological associations graph'
  )
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+r`,
    'Reset',
    'Biological associations graph'
  )
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+s`,
    'Save',
    'Biological associations graph'
  )
})

function loadGraph(id) {
  graph.value.resetStore()
  graph.value.setGraph(id)
  setParam(RouteNames.NewBiologicalAssociationGraph, {
    biological_associations_graph_id: id
  })
}

function saveGraph() {
  graph.value.save().then(({ biologicalAssociationGraph }) => {
    TW.workbench.alert.create(
      'Biological association(s) were successfully saved.',
      'notice'
    )

    if (biologicalAssociationGraph?.id) {
      setParam(RouteNames.NewBiologicalAssociationGraph, {
        biological_associations_graph_id: biologicalAssociationGraph.id
      })
    }
  })
}

function addBiologicalAssociationsToGraph(ids) {
  const { loadBiologicalAssociations, updateObjectByUuid } = graph.value

  loadBiologicalAssociations(ids).then((biologicalAssociations) =>
    biologicalAssociations.forEach(({ uuid }) => {
      updateObjectByUuid(uuid, { isUnsaved: true })
    })
  )
}

function reset() {
  graph.value.resetStore()
  setParam(
    RouteNames.NewBiologicalAssociationGraph,
    'biological_associations_graph_id'
  )
}
</script>

<style scoped>
.graph-section {
  position: relative;
}
</style>

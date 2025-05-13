<template>
  <VSpinner v-if="isLoading && !modalVisible" />
  <NavBar
    :gz="gz"
    :projects-user-is-member-of="projectsUserIsMemberOf"
    v-model="selectedProjects"
    :save-disabled="saveDisabled"
    @save-gz="() => saveGz()"
    @reset-gz="() => reset()"
  />

  <BlockLayout :warning="!gz.id">
    <template #header>
      <h3>Gazetteer</h3>
    </template>

    <template #options>
      <div
        v-if="gz.id"
        class="horizontal-left-content gap-small"
      >
        <RadialAnnotator :global-id="gz.global_id" />
        <RadialNavigation :global-id="gz.global_id" />
      </div>
    </template>

    <template #body>
      <div id="gazetteer-panels">

        <NonGeoData
          v-model:gz="gz"
          v-model:projects="selectedProjects"
          :projects-user-is-member-of="projectsUserIsMemberOf"
          class="panel content item-1-1"
        />

        <ShapeChoosers
          v-if="!gz.id"
          :shapes="leafletShapes"
          @new-shape="(data, type) => addToShapes(data, type)"
          @shapes-updated="(shape) => addToShapes(shape, GZ_LEAFLET)"
          @modal-visible="(visible) => (modalVisible = visible)"
          class="panel content item-1-2"
        </ShapeChoosers>

        <ShapeListAndPreview
          :gz-saved="!!gz.id"
          :geojson-shape="previewShape?.shape"
          :raw-shapes="shapes"
          @deleteShape="(shape) => removeFromShapes(shape)"
          @previewing="(bool) => (previewing = bool)"
          v-model="operationIsUnion"
          class="right-column"
        />

      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import NavBar from './components/NavBar.vue'
import NonGeoData from './components/NonGeoData.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigation from '@/components/radials/navigation/radial.vue'
import SetParam from '@/helpers/setParam'
import ShapeListAndPreview from './components/ShapeListAndPreview.vue'
import ShapeChoosers from './components/ShapeChoosers.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { Gazetteer } from '@/routes/endpoints'
import { computed, onMounted, ref, watch } from 'vue'
import { getCurrentUserId } from '@/helpers'
import { randomUUID } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import { removeFromArray } from '@/helpers/arrays'
import { URLParamsToJSON } from '@/helpers/url/parse'
import { usePopstateListener } from '@/composables'
import { User } from '@/routes/endpoints'
import {
  GZ_POINT,
  GZ_WKT,
  GZ_LEAFLET,
  GZ_COMBINE_GA,
  GZ_COMBINE_GZ,
  GZ_DATABASE
} from '@/constants/index.js'

const shapes = ref([])
const gz = ref({})
const isLoading = ref(false)
const modalVisible = ref(false)
const selectedProjects = ref([])
// Shapes are combined by Union if true, Intersection if false
const operationIsUnion = ref(true)

const previewing = ref(false)
const previewShape = ref(null)
// If the operation at the time of the cached preview shape was Union
const previewOperationIsUnion = ref(null)
const projectsUserIsMemberOf = ref([])

const leafletShapes = computed(() => {
  return shapes.value.map((item) => item.shape)
})

const saveDisabled = computed(() => {
  const numShapes = shapes.value.length
  if (!gz.value.name || numShapes == 0) {
    return true
  }

  if (numShapes > 1) {
    return false
  }

  // numShapes == 1
  // We're not allowing save of a single GA or GZ (i.e. cloning) - use alternate
  // names for that (though this restriction is easily circumvented by, e.g.,
  // selecting a ga/gz and then adding a point that's contained by it)
  return (
    shapes.value[0].type == GZ_COMBINE_GA ||
    shapes.value[0].type == GZ_COMBINE_GZ
  )
})

watch(
  previewing,
  (newVal) => {
    if (newVal) {
      previewGz()
    }
  }
)

watch(
  operationIsUnion, () => (previewGz()), { immediate: true }
)

const { gazetteer_id } = URLParamsToJSON(location.href)

if (gazetteer_id) {
  loadGz(gazetteer_id)
}

usePopstateListener(() => {
  const { gazetteer_id } = URLParamsToJSON(location.href)
  if (gazetteer_id) {
    loadGz(gazetteer_id)
  } else {
    reset()
  }
})

function loadGz(gzId) {
  isLoading.value = true
  Gazetteer.find(gzId, { embed: ['shape'] })
    .then(({ body }) => {
      gz.value = body
      shapes.value = [
        {
          shape: body.shape,
          type: GZ_DATABASE,
          uuid: randomUUID()
        }
      ]
      setPreviewData(shapes.value[0], operationIsUnion.value)
    })
    .catch(() => {})
    .finally(() => { isLoading.value = false })
}

function setPreviewData(shape, union) {
  previewShape.value = shape
  previewOperationIsUnion.value = union
}

function saveGz() {
  if (gz.value.id) {
    updateGz()
  } else {
    saveNewGz()
  }
}

function combineShapesToGz() {
  const geojson = shapes.value
    .filter((item) => item.type == GZ_LEAFLET)
    .map((item) => JSON.stringify(item.shape))

  const wkt = shapes.value
    .filter((item) => item.type == GZ_WKT)
    .map((item) => item.shape)

  const points = shapes.value
    .filter((item) => item.type == GZ_POINT)
    .map((item) => JSON.stringify(item.shape))

  const gaCombine = shapes.value
    .filter((item) => item.type == GZ_COMBINE_GA)
    .map((item) => item.shape.id)

  const gzCombine = shapes.value
    .filter((item) => item.type == GZ_COMBINE_GZ)
    .map((item) => item.shape.id)

  const gazetteer = {
    name: gz.value.name,
    iso_3166_a2: gz.value.iso_3166_a2,
    iso_3166_a3: gz.value.iso_3166_a3,
    shapes: {
      geojson,
      wkt,
      points,
      ga_combine: gaCombine,
      gz_combine: gzCombine
    }
  }

  return gazetteer
}

function shapesUpdated() {
  // Bust the preview cache
  previewShape.value = null
  previewOperationIsUnion.value = null
  if (previewing.value && !gz.value.id) {
    previewGz()
  }
}

function previewGz() {
  if (previewCacheIsValid() || shapes.value.length == 0) {
    return
  }

  const payload = {
    gazetteer: combineShapesToGz(),
    geometry_operation_is_union: operationIsUnion.value,
    embed: ['shape']
  }

  isLoading.value = true
  Gazetteer.preview(payload)
    .then(({ body }) => {
      previewShape.value =
        {
          shape: body.shape,
          type: GZ_LEAFLET,
          uuid: randomUUID()
        }
      previewOperationIsUnion.value = operationIsUnion.value
    })
    .catch(() => { previewShape.value = null })
    .finally(() => { isLoading.value = false})
}

function previewCacheIsValid() {
  return previewShape?.value &&
    previewOperationIsUnion?.value == operationIsUnion.value
}

function saveNewGz() {
  const gazetteer = combineShapesToGz()
  const payload = {
    gazetteer,
    geometry_operation_is_union: operationIsUnion.value,
    projects: selectedProjects.value,
    embed: ['shape']
  }

  isLoading.value = true
  Gazetteer.create(payload)
    .then(({ body }) => {
      gz.value = body
      shapes.value = [
        {
          shape: gz.value.shape,
          type: GZ_DATABASE,
          uuid: randomUUID()
        }
      ]
      SetParam(RouteNames.NewGazetteer, 'gazetteer_id', gz.value.id)
      shapesUpdated()
      setPreviewData(shapes.value[0], operationIsUnion.value)
      TW.workbench.alert.create('New gazetteer created.', 'notice')
    })
    .catch(() => {})
    .finally(() => { isLoading.value = false })
}

function updateGz() {
  const payload = {
    gazetteer: {
      name: gz.value.name,
      iso_3166_a2: gz.value.iso_3166_a2,
      iso_3166_a3: gz.value.iso_3166_a3
    },
    embed: ['shape']
  }

  isLoading.value = true
  Gazetteer.update(gz.value.id, payload)
    .then(({ body }) => {
      gz.value = body
      TW.workbench.alert.create('Gazetteer updated.', 'notice')
    })
    .catch(() => {})
    .finally(() => { isLoading.value = false })
}

function reset() {
  shapes.value = []
  previewing.value = true
  previewShape.value = null
  previewOperationIsUnion.value = null
  gz.value = {}
  selectedProjects.value = []
  operationIsUnion.value = true
  SetParam(RouteNames.NewGazetteer, 'gazetteer_id')
}

function addToShapes(shape, type) {
  switch(type) {
    case GZ_LEAFLET:
    case GZ_POINT:
    case GZ_COMBINE_GA:
    case GZ_COMBINE_GZ:
      shapes.value.push({
        uuid: randomUUID(),
        type,
        shape
      })
      break
    case GZ_WKT:
      shapes.value.push({
        uuid: shape.uuid,
        type,
        shape: shape.wkt
      })
      break
  }
  TW.workbench.alert.create('Shape added.', 'notice')
  shapesUpdated()
}

function removeFromShapes(shape) {
  removeFromArray(shapes.value, shape, { property: 'uuid' })
  shapesUpdated()
}

onMounted(() => {
  User.projects(getCurrentUserId())
    .then(({ body }) => {
      projectsUserIsMemberOf.value = body
    })
    .catch(() => {})
})
</script>

<style lang="scss" scoped>
.name-input {
  width: 400px;
}

.geolist {
  margin-bottom: 2em;
}

.top-options {
  display: flex;
  align-items: flex-start;
  gap: 2em;
}

#gazetteer-panels {
  display: grid;
  grid-template-columns: 250px 1fr;
  grid-column-gap: 1em;
  grid-row-gap: 0.5em;
}

.right-column {
  grid-column: 2;
  grid-row: 1 / 3;
}

.item-1-1 {
  grid-column: 1;
  grid-row: 1;
  min-height: 250px; // right-column height with map is 2 * 265 = 530
}

.item-1-2 {
  grid-column: 1;
  grid-row: 2;
  min-height: 250px;
}
</style>
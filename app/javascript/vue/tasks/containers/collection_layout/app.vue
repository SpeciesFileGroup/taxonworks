<template>
  <div class="collection-layout-task">
    <h1>Collection layout</h1>

    <!-- Top Panel -->
    <div class="top-panel panel content">

      <!-- Building section: find or create -->
      <section class="building-section">
        <h3>Building</h3>

        <div
          v-if="building"
          class="horizontal-left-content gap-small middle"
        >
          <strong v-html="building.object_tag || building.name" />
          <RadialAnnotator :global-id="building.global_id" />
          <VBtn
            color="primary"
            medium
            @click="clearBuilding"
          >
            Change
          </VBtn>
        </div>

        <div
          v-else
          class="horizontal-left-content gap-small middle flex-wrap"
        >
          <VAutocomplete
            url="/containers/autocomplete"
            placeholder="Find existing building…"
            param="term"
            label="label"
            :add-param="{ type: 'Container::Building' }"
            @get-item="selectBuilding"
          />
          <span class="building-divider">or</span>
          <input
            v-model="buildingName"
            type="text"
            placeholder="New building name"
            class="normal-input"
          />
          <label>
            x
            <input
              v-model.number="buildingSizeX"
              type="number"
              min="1"
              placeholder="none"
              class="normal-input small-input"
            />
          </label>
          <label>
            y
            <input
              v-model.number="buildingSizeY"
              type="number"
              min="1"
              placeholder="none"
              class="normal-input small-input"
            />
          </label>
          <label>
            z
            <input
              v-model.number="buildingSizeZ"
              type="number"
              min="1"
              placeholder="none"
              class="normal-input small-input"
            />
          </label>
          <VBtn
            color="create"
            medium
            :disabled="!buildingName.trim()"
            @click="createBuilding"
          >
            Create
          </VBtn>
          <RecentBuildings @select="selectBuildingFromRecent" />
          <span
            v-if="buildingError"
            class="feedback-warning"
          >{{ buildingError }}</span>
        </div>
      </section>

      <!-- Specification form -->
      <section :class="['specification-section', { 'section-disabled': !building }]">
        <h3>Add rooms, cabinets &amp; drawers</h3>
        <fieldset :disabled="!building">
          <div class="horizontal-left-content gap-medium flex-wrap specification-row">
            <label>
              Rooms
              <input
                v-model.number="roomCount"
                type="number"
                min="1"
                class="normal-input small-input"
              />
            </label>

            <label>
              Cabinets per room
              <input
                v-model.number="cabinetCount"
                type="number"
                min="1"
                class="normal-input small-input"
              />
            </label>

            <label>
              Drawer type
              <select
                v-model="drawerType"
                class="normal-input"
              >
                <option
                  v-for="dt in drawerTypeOptions"
                  :key="dt.key"
                  :value="dt.key"
                >
                  {{ dt.label }}
                </option>
              </select>
            </label>

            <label>
              Cabinet size x
              <input
                v-model.number="cabinetSizeX"
                type="number"
                min="1"
                placeholder="none"
                class="normal-input small-input"
              />
            </label>

            <label>
              Cabinet size y
              <input
                v-model.number="cabinetSizeY"
                type="number"
                min="1"
                placeholder="none"
                class="normal-input small-input"
              />
            </label>

            <label>
              Cabinet size z
              <input
                v-model.number="cabinetSizeZ"
                type="number"
                min="1"
                placeholder="none"
                class="normal-input small-input"
              />
            </label>

            <label>
              Drawers per cabinet
              <input
                v-model.number="drawerCount"
                type="number"
                min="1"
                :max="maxDrawers ?? undefined"
                class="normal-input small-input"
              />
            </label>

            <label>
              % empty
              <input
                v-model.number="defaultPercentEmpty"
                type="number"
                min="0"
                max="100"
                step="any"
                placeholder="none"
                class="normal-input small-input"
              />
            </label>

            <label>
              % earmarked
              <input
                v-model.number="defaultPercentEarmarked"
                type="number"
                min="0"
                max="100"
                step="any"
                placeholder="none"
                class="normal-input small-input"
              />
            </label>

            <VBtn
              color="create"
              medium
              :disabled="!scaffoldValid || scaffolding"
              @click="addRooms"
            >
              {{ scaffolding ? 'Adding…' : 'Add' }}
            </VBtn>
          </div>

          <!-- Info row -->
          <div class="info-row gap-medium horizontal-left-content flex-wrap">
            <em v-if="cabinetDimensions">
              {{ selectedDrawerType.label }}:
              {{ cabinetDimensions.x }}&thinsp;×&thinsp;{{ cabinetDimensions.y }} grid
              (max {{ maxDrawers }} drawers per cabinet)
            </em>
            <em class="preview-text">{{ previewText }}</em>
          </div>

          <span
            v-if="scaffoldError"
            class="feedback-warning"
          >{{ scaffoldError }}</span>
        </fieldset>
      </section>
    </div>

    <!-- Bottom Panel -->
    <div class="bottom-panel gap-medium">

      <!-- Left: container list -->
      <div class="container-list panel content">
        <h3>Containers in building</h3>
        <div
          v-if="!building"
          class="muted"
        >
          Select or create a building to see containers.
        </div>
        <ul
          v-else-if="containerList.length"
          class="container-list-items"
        >
          <li
            v-for="item in containerList"
            :key="item.id"
            :style="{ marginLeft: (item.depth * 1.5) + 'em' }"
          >
            <span class="container-type-badge">{{ item.typeName }}</span>
            {{ item.name }}
          </li>
        </ul>
        <div
          v-else
          class="muted"
        >
          No containers yet. Use &lsquo;Add&rsquo; above.
        </div>
      </div>

      <!-- Right: building grid -->
      <div class="grid-panel panel content">
        <BuildingGrid
          ref="buildingGridRef"
          :building-id="building?.id ?? null"
          @add-container="onGridAddContainer"
        />
      </div>

    </div>

  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import AjaxCall from '@/helpers/ajaxCall'
import { Container } from '@/routes/endpoints'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RecentBuildings from './components/RecentBuildings.vue'
import BuildingGrid from './components/BuildingGrid.vue'

defineOptions({ name: 'CollectionLayout' })

// ── Drawer types (loaded dynamically from /containers/container_types) ────────
const drawerTypeOptions = ref([])

onMounted(async () => {
  const { body } = await Container.types()
  const drawerEntries = (body || [])
    .filter(t => t.type && t.type.startsWith('Container::Drawer'))
    .map(t => ({
      key:        t.type,
      label:      t.name || t.type.split('::').pop(),
      dimensions: t.dimensions || null
    }))
    .sort((a, b) => {
      // Base Drawer first, then alphabetical
      if (a.key === 'Container::Drawer') return -1
      if (b.key === 'Container::Drawer') return  1
      return a.label.localeCompare(b.label)
    })
  drawerTypeOptions.value = drawerEntries
})

// ── State ────────────────────────────────────────────────────────────────────
const building      = ref(null)
const buildingName  = ref('')
const buildingSizeX = ref(null)
const buildingSizeY = ref(null)
const buildingSizeZ = ref(null)
const buildingError = ref('')

const drawerType              = ref('Container::Drawer')
const cabinetSizeX            = ref(null)
const cabinetSizeY            = ref(null)
const cabinetSizeZ            = ref(null)
const roomCount               = ref(1)
const cabinetCount            = ref(1)
const drawerCount             = ref(1)
const defaultPercentEmpty     = ref(null)
const defaultPercentEarmarked = ref(null)
const scaffolding             = ref(false)
const scaffoldError           = ref('')

const containerList   = ref([])
const buildingGridRef = ref(null)

// ── Drawer type helpers ───────────────────────────────────────────────────────
const selectedDrawerType = computed(() =>
  drawerTypeOptions.value.find(t => t.key === drawerType.value)
)

const cabinetDimensions = computed(() => selectedDrawerType.value?.dimensions ?? null)

const maxDrawers = computed(() => {
  const d = cabinetDimensions.value
  return d ? d.x * d.y * d.z : null
})

// Clamp drawerCount when switching to a type with a lower limit
watch(maxDrawers, (max) => {
  if (max !== null && drawerCount.value > max) {
    drawerCount.value = max
  }
})

// ── Computed ─────────────────────────────────────────────────────────────────
const previewText = computed(() => {
  const r = roomCount.value    || 0
  const c = cabinetCount.value || 0
  const d = drawerCount.value  || 0
  return `${r} room(s) × ${c} cabinet(s) × ${d} drawer(s) = ${r * c * d} drawers total`
})

const scaffoldValid = computed(() =>
  building.value     &&
  roomCount.value    > 0 &&
  cabinetCount.value > 0 &&
  drawerCount.value  > 0
)

// ── Building: find or create ──────────────────────────────────────────────────
async function selectBuilding({ id }) {
  buildingError.value = ''
  const { body } = await AjaxCall('get', `/containers/${id}.json`)
  if (body?.id) {
    building.value = body
    await refreshData()
  } else {
    buildingError.value = 'Could not load building.'
  }
}

function selectBuildingFromRecent(item) {
  building.value = item
  refreshData()
}

async function createBuilding() {
  buildingError.value = ''

  const attrs = { type: 'Container::Building', name: buildingName.value.trim() }
  if (buildingSizeX.value) attrs.size_x = buildingSizeX.value
  if (buildingSizeY.value) attrs.size_y = buildingSizeY.value
  if (buildingSizeZ.value) attrs.size_z = buildingSizeZ.value

  const { body } = await AjaxCall('post', '/containers.json', { container: attrs })
  if (body?.id) {
    building.value     = body
    buildingName.value = ''
    buildingSizeX.value = null
    buildingSizeY.value = null
    buildingSizeZ.value = null
    await refreshData()
  } else {
    buildingError.value = 'Could not create building.'
  }
}

function clearBuilding() {
  building.value      = null
  buildingName.value  = ''
  buildingSizeX.value = null
  buildingSizeY.value = null
  buildingSizeZ.value = null
  buildingError.value = ''
  containerList.value = []
}

// ── Add rooms/cabinets/drawers ────────────────────────────────────────────────
async function addRooms() {
  scaffoldError.value = ''
  scaffolding.value   = true

  const payload = {
    building_id:  building.value.id,
    cabinet_type: (drawerType.value || 'Container::Drawer').replace(/Drawer/g, 'Cabinet'),
    rooms:        roomCount.value,
    cabinets:     cabinetCount.value,
    drawers:      drawerCount.value
  }

  if (cabinetSizeX.value !== null && cabinetSizeX.value !== '')
    payload.cabinet_size_x = cabinetSizeX.value

  if (cabinetSizeY.value !== null && cabinetSizeY.value !== '')
    payload.cabinet_size_y = cabinetSizeY.value

  if (cabinetSizeZ.value !== null && cabinetSizeZ.value !== '')
    payload.cabinet_size_z = cabinetSizeZ.value

  if (defaultPercentEmpty.value !== null && defaultPercentEmpty.value !== '')
    payload.asserted_percent_empty = defaultPercentEmpty.value

  if (defaultPercentEarmarked.value !== null && defaultPercentEarmarked.value !== '')
    payload.asserted_percent_earmarked = defaultPercentEarmarked.value

  const { body } = await AjaxCall('post', '/tasks/containers/collection_layout/scaffold.json', payload)

  scaffolding.value = false

  if (body?.created_rooms !== undefined) {
    await Promise.all([
      refreshData(),
      buildingGridRef.value?.reload()
    ])
  } else {
    scaffoldError.value = body?.error || 'Failed to add containers.'
  }
}

// ── Grid ──────────────────────────────────────────────────────────────────────
function onGridAddContainer({ container, col, row }) {
  // TODO: persist container at (col, row) within the building once coordinate
  // storage is implemented on ContainerItem or Container.
  console.log('Add container', container.id, 'at', col, row)
}

// ── Data refresh ──────────────────────────────────────────────────────────────
async function refreshData() {
  if (!building.value) return

  const { body } = await AjaxCall('get', '/tasks/containers/collection_visualization/collection_tree.json', {
    params: { building_id: building.value.id }
  })

  if (body?.id) {
    containerList.value = flattenTree(body, 0)
  }
}

function flattenTree(node, depth) {
  const typeName = node.type ? node.type.split('::').slice(1).join('::') : ''
  const rows = [{ id: node.id, name: node.name, typeName, depth }]
  for (const child of node.children || []) {
    rows.push(...flattenTree(child, depth + 1))
  }
  return rows
}
</script>

<style scoped>
.collection-layout-task {
  padding: 1em;
}

.top-panel {
  margin-bottom: 1em;
}

.building-section,
.specification-section {
  margin-bottom: 1em;
}

.section-disabled {
  opacity: 0.45;
  pointer-events: none;
}

.building-divider {
  color: #999;
}

.specification-row {
  align-items: flex-end;
  margin-bottom: 0.5em;
}

.info-row {
  font-size: 0.9em;
  color: #555;
  min-height: 1.4em;
}

.preview-text {
  color: #666;
}

.small-input {
  width: 7em;
}

.bottom-panel {
  display: flex;
  gap: 1em;
}

.container-list {
  flex: 0 0 340px;
  min-width: 240px;
  overflow-y: auto;
  max-height: 60vh;
}

.container-list-items {
  list-style: none;
  padding: 0;
  margin: 0;
  font-size: 0.9em;
}

.container-list-items li {
  padding: 2px 0;
}

.container-type-badge {
  background: #e8e8e8;
  border-radius: 3px;
  padding: 0 4px;
  font-size: 0.8em;
  margin-right: 4px;
  color: #555;
}

.grid-panel {
  flex: 1 1 0;
  min-width: 0;
}

.muted {
  color: #999;
  font-style: italic;
}
</style>

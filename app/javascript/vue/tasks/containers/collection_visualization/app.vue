<template>
  <div class="collection-visualization-task">
    <h1>Collection visualization</h1>

    <!-- Building selector -->
    <div class="top-panel panel content">
      <section>
        <h3>Building</h3>
        <div
          v-if="building"
          class="horizontal-left-content gap-small middle"
        >
          <strong v-html="building.object_tag || building.name" />
          <RadialAnnotator :global-id="building.global_id" />
          <VBtn
            color="default"
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
            placeholder="Find a building…"
            param="term"
            label="label"
            :add-param="{ type: 'Container::Building' }"
            @get-item="selectBuilding"
          />
        </div>
      </section>

      <!-- Visualization type selector -->
      <section class="type-section">
        <h3>Visualization</h3>
        <div class="horizontal-left-content gap-medium">
          <label
            v-for="vt in VISUALIZATION_TYPES"
            :key="vt.key"
            class="viz-type-option"
          >
            <input
              v-model="vizType"
              type="radio"
              :value="vt.key"
            />
            {{ vt.label }}
          </label>
        </div>
      </section>
    </div>

    <!-- Visualization panel -->
    <div class="viz-panel panel content">
      <div
        v-if="!building"
        class="muted"
      >
        Select a building to visualize.
      </div>
      <VSpinner v-else-if="loading" />
      <template v-else>
        <template v-if="vizType === 'treemap'">
          <div
            ref="treemapRef"
            class="treemap-container"
          />
        </template>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, nextTick, onBeforeUnmount, onMounted } from 'vue'
import AjaxCall from '@/helpers/ajaxCall'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'

defineOptions({ name: 'CollectionVisualization' })

const VISUALIZATION_TYPES = [
  { key: 'treemap', label: 'Treemap' }
]

// ── State ─────────────────────────────────────────────────────────────────────
const building   = ref(null)
const vizType    = ref('treemap')
const loading    = ref(false)
const treemapRef = ref(null)
let   chart      = null

// ── Building ──────────────────────────────────────────────────────────────────

async function selectBuilding({ id }) {
  const { body } = await AjaxCall('get', `/containers/${id}.json`)
  if (body?.id) building.value = body
}

function clearBuilding() {
  building.value = null
  chart?.dispose()
  chart = null
}

onMounted(async () => {
  const params = new URLSearchParams(window.location.search)
  const containerId = params.get('container_id')
  if (containerId) {
    const { body } = await AjaxCall('get', `/containers/${containerId}.json`)
    if (body?.id) building.value = body
  }
})

// ── Data + render — re-run whenever building or vizType changes ───────────────

watch([building, vizType], async ([b]) => {
  if (!b) return
  loading.value = true
  await loadAndRender()
})

async function loadAndRender() {
  if (vizType.value === 'treemap') {
    const { body } = await AjaxCall('get', '/tasks/containers/collection_visualization/collection_tree.json', {
      params: { building_id: building.value.id }
    })
    if (body?.id) {
      // Clear spinner before nextTick so the treemap <div> is in the DOM
      // when ECharts initialises — treemapRef is null while VSpinner is mounted.
      loading.value = false
      await nextTick()
      renderTreemap(body)
    }
  }
}

// ── ECharts treemap ───────────────────────────────────────────────────────────

function renderTreemap(treeData) {
  if (!treemapRef.value || !window.echarts) return

  chart ||= window.echarts.init(treemapRef.value)

  chart.setOption({
    tooltip: { formatter: (info) => `${info.name}<br/>drawers: ${info.value}` },
    series: [
      {
        type: 'treemap',
        name: treeData.name,
        data: treeData.children || [],
        roam: true,
        leafDepth: 2,
        label: { show: true, formatter: '{b}' },
        breadcrumb: { show: true },
        itemStyle: { borderColor: '#fff' },
        levels: [
          { itemStyle: { borderColor: '#333', borderWidth: 8, gapWidth: 8 } },
          { itemStyle: { borderColor: '#777', borderWidth: 4, gapWidth: 4 } },
          {
            colorSaturation: [0.35, 0.5],
            itemStyle: { borderWidth: 2, gapWidth: 2, borderColorSaturation: 0.6 }
          }
        ]
      }
    ]
  })
}

onBeforeUnmount(() => chart?.dispose())
</script>

<style scoped>
.collection-visualization-task {
  padding: 1em;
}

.top-panel {
  margin-bottom: 1em;
  display: flex;
  flex-direction: column;
  gap: 1em;
}

.type-section {
  border-top: 1px solid #eee;
  padding-top: 0.75em;
}

.viz-type-option {
  display: flex;
  align-items: center;
  gap: 0.4em;
  cursor: pointer;
  font-size: 0.95em;
}

.viz-panel {
  min-height: 400px;
}

.treemap-container {
  width: 100%;
  height: 60vh;
}

.muted {
  color: #999;
  font-style: italic;
}
</style>

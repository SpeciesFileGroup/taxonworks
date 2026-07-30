<template>
  <div id="browse-otu">
    <select-otu
      :otus="otus"
      @selected="loadOtu"
    />
    <VSpinner
      v-if="settingStore.isLoading"
      legend="Loading..."
      full-screen
      :logo-size="{ width: '100px', height: '100px' }"
    />
    <div class="flex-separate middle">
      <div class="horizontal-left-content">
        <ul
          v-if="navigate && false"
          class="no_bullets"
        >
          <li v-for="item in navigate.previous">
            <a
              :href="`${RouteNames.BrowseOtu}?otu_id=${item.id}`"
              v-html="item.object_tag"
            />
          </li>
        </ul>
      </div>
    </div>
    <template v-if="otuStore.otu && otuStore.taxonName">
      <HeaderBar
        class="separate-bottom"
        :menu="menu"
        :otu="otuStore.otu"
        :preferences="preferences"
        :storage-key="KEY_STORAGE"
      />
      <div class="separate-top separate-bottom"></div>

      <div class="container-2xl mx-auto flex-col gap-medium">
        <div
          v-for="(row, rowIndex) in rows"
          :key="rowIndex"
          class="browse-otu-row gap-medium"
          :class="{ 'browse-otu-row--split': row.columns.length > 1 }"
        >
          <div
            v-for="(column, columnIndex) in row.columns"
            :key="columnIndex"
            class="browse-otu-row__column flex-col gap-medium"
          >
            <component
              v-for="element in column"
              :key="element"
              class="full_width"
              :title="PANEL_COMPONENTS[element].title"
              :status="PANEL_COMPONENTS[element].status"
              v-bind="PANEL_COMPONENTS[element]?.bind"
              :otu="otuStore.otu"
              :otus="otuStore.selectedOtus"
              :taxon-name="otuStore.taxonName"
              :is="PANEL_COMPONENTS[element].component"
            />
          </div>
        </div>
      </div>
    </template>
    <div
      v-else
      class="container-2xl mx-auto"
    >
      <SearchOtu
        class="margin-medium-top"
        @select="loadOtu"
      />
    </div>
  </div>
</template>

<script setup>
import { computed, ref, onBeforeMount } from 'vue'
import HeaderBar from './components/HeaderBar/HeaderBar.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import SearchOtu from './components/Navbar/NavbarSearchOtu.vue'
import { RouteNames } from '@/routes/routes'
import { useUserPreferences } from '@/composables'
import { useOtuStore } from './store'
import { PANEL_COMPONENTS, migrateTaskPreferences } from './constants'
import { resolveLayoutRows, flattenRows } from './utils/resolveLayoutRows.js'
import ShowForThisGroup from '@/tasks/nomenclature/new_taxon_name/helpers/showForThisGroup.js'
import { useSettingsStore } from './store'

defineOptions({
  name: 'BrowseOtu'
})

const KEY_STORAGE = 'task::BrowseOtus'

const { preferences, loadPreferences, setPreference } = useUserPreferences()
const otuStore = useOtuStore()
const settingStore = useSettingsStore()

loadPreferences().then(() => {
  const stored = preferences.value?.layout?.[KEY_STORAGE]
  const migrated = migrateTaskPreferences(stored)

  if (migrated !== stored) {
    setPreference(KEY_STORAGE, migrated)
  }
})

const taskPreferences = computed(
  () => preferences.value?.layout?.[KEY_STORAGE] || {}
)

const rows = computed(() =>
  resolveLayoutRows(taskPreferences.value)
    .map((row) => ({
      columns: row.columns
        .map((column) =>
          column.filter((key) => showForRanks(PANEL_COMPONENTS[key]))
        )
        .filter((column) => column.length)
    }))
    .filter((row) => row.columns.length)
)

const menu = computed(() =>
  flattenRows(rows.value).map((name) => PANEL_COMPONENTS[name].title)
)

const navigate = ref()
const otus = ref([])

onBeforeMount(() => {
  otuStore.initFromUrl()
})

function loadOtu({ id }) {
  window.open(`${RouteNames.BrowseOtu}?otu_id=${id}`, '_self')
}

function showForRanks(section) {
  const rankGroup = section.rankGroup
  return rankGroup
    ? otuStore.taxonName
      ? ShowForThisGroup(rankGroup, otuStore.taxonName)
      : section.otu
    : true
}
</script>

<style lang="scss">
#browse-otu {
  .anchor {
    scroll-margin-top: 9rem;
  }
  .browse-otu-row {
    display: grid;
    grid-template-columns: minmax(0, 1fr);
  }
  // `min-width: 0` keeps wide panel tables from blowing the grid track out
  .browse-otu-row__column {
    min-width: 0;
  }
  @media all and (min-width: 1200px) {
    .browse-otu-row--split {
      grid-template-columns: minmax(0, 2fr) minmax(0, 1fr);
    }
    // The shorter column's last panel absorbs the leftover height, so a split
    // row ends flush instead of ragged. `.panel` is already a flex column, so
    // the body takes the space rather than leaving it below the content.
    .browse-otu-row--split .browse-otu-row__column > :last-child {
      flex-grow: 1;

      > .body {
        flex-grow: 1;
      }
    }
  }
  .autocomplete-search-bar {
    input {
      width: 500px;
    }
  }
  .container {
    margin: 0 auto;
    width: 1240px;
    min-width: auto;
  }
  .section-title {
    text-transform: uppercase;
    font-size: 14px;
  }
  .expand-box {
    width: 24px;
    height: 24px;
    padding: 0px;
    background-size: 10px;
    background-position: center;
  }

  .mark-box {
    width: 10px;
    height: 10px;
    padding: 0px;
  }
}
</style>

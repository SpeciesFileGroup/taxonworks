<template>
  <div id="browse-otu">
    <select-otu
      :otus="otus"
      @selected="loadOtu"
    />
    <VSpinner
      v-if="isLoading"
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
        <template v-if="otu">
          <VAutocomplete
            class="float_right separate-left separate-right autocomplete-search-bar"
            url="/otus/autocomplete"
            placeholder="Search a otu"
            param="term"
            clear-after
            label="label_html"
            @getItem="(e) => otuStore.loadOtu(e.id)"
          />
          <ul
            v-if="navigate"
            class="no_bullets"
          >
            <li v-for="item in navigate.next">
              <a
                :href="`${RouteNames.BrowseOtu}?otu_id=${item.id}`"
                v-html="item.object_tag"
              />
            </li>
          </ul>
        </template>
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
        <template
          v-for="element in sections"
          :key="element"
        >
          <component
            v-if="showForRanks(PANEL_COMPONENTS[element])"
            class="full_width"
            :title="PANEL_COMPONENTS[element].title"
            :status="PANEL_COMPONENTS[element].status"
            :otu="otuStore.otu"
            :otus="otuStore.selectedOtus"
            :taxon-name="otuStore.taxonName"
            :is="PANEL_COMPONENTS[element].component"
          />
        </template>
      </div>
    </template>
    <SearchOtu
      v-else
      class="container"
      @select="loadOtu"
    />
  </div>
</template>

<script setup>
import { computed, ref, onBeforeMount } from 'vue'
import HeaderBar from './components/HeaderBar/HeaderBar.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

import VAutocomplete from '@/components/ui/Autocomplete'
import SearchOtu from './components/Navbar/NavbarSearchOtu.vue'
import { RouteNames } from '@/routes/routes'
import { useUserPreferences } from '@/composables'
import { useOtuStore } from './store'
import { PANEL_COMPONENTS, DEFAULT_PREFERENCES } from './constants'
import ShowForThisGroup from '@/tasks/nomenclature/new_taxon_name/helpers/showForThisGroup.js'

defineOptions({
  name: 'BrowseOtu'
})

const KEY_STORAGE = 'task::BrowseOtus'

const otuStore = useOtuStore()

const isLoading = ref(false)

const { preferences, loadPreferences } = useUserPreferences()

loadPreferences().then(() => {
  const taskPreferences = preferences.value?.layout[KEY_STORAGE]

  if (
    !taskPreferences ||
    taskPreferences.preferenceSchema < DEFAULT_PREFERENCES.preferenceSchema
  ) {
    preferences.value.layout[KEY_STORAGE] = { ...DEFAULT_PREFERENCES }
  }
})

const sections = computed(
  () => preferences.value.layout?.[KEY_STORAGE]?.sections || []
)

const menu = computed(() => {
  const sections = preferences.value?.layout?.[KEY_STORAGE]?.sections || []

  return sections
    .filter((name) => PANEL_COMPONENTS[name])
    .map((name) => PANEL_COMPONENTS[name].title)
})

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

<template>
  <div id="browse-otu">
    <select-otu
      :otus="otus"
      @selected="loadOtu"
    />
    <VSpinner
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px' }"
      v-if="isLoading"
    />
    <div class="flex-separate middle">
      <div class="horizontal-left-content">
        <ul
          v-if="navigate"
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
      />
      <div class="separate-top separate-bottom"></div>

      <VDraggable
        v-if="preferences?.layout?.[KEY_STORAGE]"
        handle=".handle"
        :item-key="(element) => element"
        v-model="preferences.layout[KEY_STORAGE].sections"
      >
        <template #item="{ element }">
          <component
            v-if="showForRanks(PANEL_COMPONENTS[element])"
            class="separate-bottom full_width"
            :title="PANEL_COMPONENTS[element].title"
            :status="PANEL_COMPONENTS[element].status"
            :otu="otuStore.otu"
            :otus="otuStore.selectedOtus"
            :taxon-name="otuStore.taxonName"
            :is="PANEL_COMPONENTS[element].component"
          />
        </template>
      </VDraggable>
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
import VDraggable from 'vuedraggable'
import { RouteNames } from '@/routes/routes'
import { useUserPreferences } from '@/composables'
import { CollectionObject, TaxonName, Otu } from '@/routes/endpoints'
import { useOtuStore, useSettingsStore } from './store'
import { PANEL_COMPONENTS, DEFAULT_PREFERENCES } from './constants'
import ShowForThisGroup from '@/tasks/nomenclature/new_taxon_name/helpers/showForThisGroup.js'

defineOptions({
  name: 'BrowseOtu'
})

const KEY_STORAGE = 'task::BrowseOtus'

const otuStore = useOtuStore()
const settings = useSettingsStore()

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

const menu = computed(() => {
  const sections = preferences.value?.layout?.[KEY_STORAGE]?.sections || []

  return sections
    .filter((name) => PANEL_COMPONENTS[name])
    .map((name) => PANEL_COMPONENTS[name].title)
})

const navigate = ref()
const otus = ref([])

onBeforeMount(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const otuId = urlParams.get('otu_id')
  const taxonId = urlParams.get('taxon_name_id')

  const collectionObjectId = urlParams.get('collection_object_id')

  if (/^\d+$/.test(otuId)) {
    otuStore.loadOtu(otuId)

    Otu.navigation(otuId).then(({ body }) => {
      navigate.value = body
    })
  } else if (taxonId) {
    TaxonName.otus(taxonId).then(({ body }) => {
      if (!body.length) {
        TW.workbench.alert.create(
          `No page available. There is no OTU for this taxon name.`,
          'notice'
        )
        return
      }

      if (body.length > 1) {
        otus.value = body
      } else {
        otuStore.loadOtu(body[0].id)
      }
    })
  } else if (collectionObjectId) {
    CollectionObject.find(collectionObjectId, {
      extend: ['taxon_determinations']
    }).then(({ body }) => {
      const id = body.taxon_determinations?.[0]?.otu_id

      if (id) {
        otuStore.loadOtu(id)
      }
    })
  } else {
    settings.isLoading = false
  }
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

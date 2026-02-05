<template>
  <div id="browse-otu">
    <select-otu
      :otus="otuList"
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
            @getItem="loadOtu"
            label="label_html"
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
    <template v-if="otu">
      <HeaderBar
        class="separate-bottom"
        :menu="menu"
        :otu="otu"
      />
      <div class="separate-top separate-bottom"></div>
      <VDraggable
        v-if="preferences[KEY_STORAGE]"
        handle=".handle"
        :item-key="(element) => element"
        v-model="preferences[KEY_STORAGE].sections"
      >
        <template #item="{ element }">
          <component
            v-if="showForRanks(COMPONENT_NAMES[element])"
            class="separate-bottom full_width"
            :title="componentNames[element].title"
            :status="componentNames[element].status"
            :otu="otu"
            :is="componentNames[element].component"
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
import {ref, onBeforeCreate } from 'vue'
import HeaderBar from './components/HeaderBar'
import VSpinner from '@/components/ui/VSpinner'

import VAutocomplete from '@/components/ui/Autocomplete'
import SearchOtu from './components/SearchOtu'
import VDraggable from 'vuedraggable'
import { RouteNames } from '@/routes/routes'
import { useUserPreferences } from '@/composables'
import { CollectionObject, TaxonName, Otu } from '@/routes/endpoints'
import { useOtuStore } from './store'
import defaultPreferences from './constants/preferences.js'
import COMPONENT_NAMES from './const/componentNames'
import ShowForThisGroup from '@/tasks/nomenclature/new_taxon_name/helpers/showForThisGroup.js'

const otuStore = useOtuStore()
const { preferences, loadPreferences } = useUserPreferences()

const KEY_STORAGE = 'task::BrowseOtus'

loadPreferences().then(() => {
  const taskPreferences = preferences.value[KEY_STORAGE]

  if (!taskPreferences || taskPreferences.preferenceSchema < defaultPreferences.preferenceSchema) {
    preferences.value[KEY_STORAGE] = { ...defaultPreferences }
  }
})



const menu = computed(() => preferences.value.sections.map(
        (name) => COMPONENT_NAMES[name].title
      ))


const isLoading = ref(false)
const navigate = ref()
const
  data() {
    return {
      isLoading: false,
      navigate: undefined,
      otuList: [],
      componentNames: COMPONENT_NAMES
    }
  },

  onBeforeCreate(() => {
    const urlParams = new URLSearchParams(window.location.search)
    const otuId = urlParams.get('otu_id')
      ? urlParams.get('otu_id')
      : location.pathname.split('/')[4]
    const taxonId = urlParams.get('taxon_name_id')

    const collectionObjectId = urlParams.get('collection_object_id')

    if (/^\d+$/.test(otuId)) {
      this.$store.dispatch(ActionNames.LoadOtus, otuId).then(() => {
        this.isLoading = false
      })
      Otu.navigation(otuId).then((response) => {
        this.navigate = response.body
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
          this.otuList = body
        } else {
          this.$store.dispatch(ActionNames.LoadOtus, body[0].id).then(() => {
            this.isLoading = false
          })
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
      this.isLoading = false
    }

})

function loadOtu(event) {
      window.open(`/tasks/otus/browse?otu_id=${event.id}`, '_self')
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

<template>
  <NavBar :class="{ 'feedback-warning': isInvalid }">
    <div
      id="browse-otu-header"
      class="container-2xl w-full mx-auto"
    >
      <div class="flex-separate align-start gap-medium">
        <template v-if="navigation">
          <ul class="breadcrumb_list">
            <li
              v-for="(item, key) in navigation.parents"
              :key="key"
              class="breadcrumb_item"
            >
              <a
                v-if="item.length === 1"
                :href="`${RouteNames.BrowseOtu}?otu_id=${item[0].id}`"
              >
                {{ key }}
              </a>
              <div
                v-else
                class="dropdown-otu"
              >
                <a>{{ key }}</a>
                <ul class="panel dropdown no_bullets">
                  <li>Parents</li>
                  <li
                    v-for="parent in item"
                    :key="parent.id"
                  >
                    <a
                      :href="`${RouteNames.BrowseOtu}?otu_id=${parent.id}`"
                      v-html="parent.object_tag"
                    />
                  </li>
                </ul>
              </div>
            </li>
            <li
              class="breadcrumb_item current_breadcrumb_position"
              v-html="navigation.current_otu.object_label"
            />
          </ul>
          <VAutocomplete
            class="autocomplete-search-bar"
            url="/otus/autocomplete"
            placeholder="Search a otu"
            param="term"
            clear-after
            label="label_html"
            @getItem="
              (e) => {
                otuStore.$reset()
                otuStore.handleOtu(e.id)
              }
            "
          />
        </template>
        <VSkeleton
          v-else
          variant="text"
          :rows="1"
        />
      </div>
      <div class="flex-separate middle">
        <div class="padding-medium-top padding-medium-bottom">
          <h3 v-html="otu.object_tag" />
          <CoordinateOtus />
        </div>
        <div class="horizontal-left-content middle gap-small">
          <button
            v-if="isInvalid"
            v-help.section.header.validButton
            class="button button-default normal-input"
            @click="openValid"
          >
            Browse current OTU
          </button>
          <QuickForms :global-id="otu.global_id" />
          <RadialAnnotator
            :global-id="otu.global_id"
            type="annotations"
          />
          <RadialObject
            :global-id="otu.global_id"
            type="annotations"
          />
          <BrowseTaxon
            v-if="otu.taxon_name_id"
            ref="browseTaxonRef"
            :object-id="otu.taxon_name_id"
          />
          <VBtn
            color="primary"
            @click="showLayoutSettings = true"
          >
            Layout settings
          </VBtn>
        </div>
      </div>
      <HeaderBarLayoutSettings
        v-if="showLayoutSettings"
        :preferences="preferences"
        :storage-key="storageKey"
        @close="showLayoutSettings = false"
      />
      <ul class="context-menu no_bullets">
        <template
          v-for="item in menu"
          :key="item"
        >
          <li v-show="showForRanks(item)">
            <a
              data-turbolinks="false"
              :href="`#${item}`"
            >
              {{ item }}
            </a>
          </li>
        </template>
      </ul>
    </div>
  </NavBar>
</template>

<script setup>
import { ref, computed, watch, onBeforeMount } from 'vue'
import { RouteNames } from '@/routes/routes'
import { Otu } from '@/routes/endpoints'
import { useHotkey } from '@/composables'
import { useOtuStore } from '../../store'
import { PANEL_COMPONENTS } from '../../constants'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import CoordinateOtus from '../CoordinateOtus.vue'
import platformKey from '@/helpers/getPlatformKey.js'
import ShowForThisGroup from '@/tasks/nomenclature/new_taxon_name/helpers/showForThisGroup.js'
import NavBar from '@/components/layout/NavBar.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator'
import RadialObject from '@/components/radials/navigation/radial.vue'
import QuickForms from '@/components/radials/object/radial.vue'
import BrowseTaxon from '@/components/taxon_names/browseTaxon.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSkeleton from '@/components/ui/VSkeleton/VSkeleton.vue'
import HeaderBarLayoutSettings from './HeaderBarLayoutSettings.vue'

const props = defineProps({
  otu: {
    type: Object,
    required: true
  },

  menu: {
    type: Array,
    required: true
  },

  preferences: {
    type: Object,
    required: true
  },

  storageKey: {
    type: String,
    required: true
  }
})

const otuStore = useOtuStore()
const browseTaxonRef = ref(null)
const navigation = ref()
const showLayoutSettings = ref(false)
const isLoading = ref(true)

const taxonName = computed(() => otuStore.taxonName)
const isInvalid = computed(
  () => taxonName.value && !taxonName.value.cached_is_valid
)

const shortcuts = ref([
  {
    keys: [platformKey(), 't'],
    handler() {
      switchNewTaxonName()
    }
  },
  {
    keys: [platformKey(), 'b'],
    handler() {
      switchBrowse()
    }
  },
  {
    keys: [platformKey(), 'm'],
    handler() {
      switchTypeMaterial()
    }
  },
  {
    keys: [platformKey(), 'e'],
    handler() {
      switchComprehensive()
    }
  }
])

useHotkey(shortcuts.value)

watch(
  () => props.otu,
  async (newVal) => {
    isLoading.value = true
    try {
      const { body } = await Otu.breadcrumbs(newVal.id)

      navigation.value = body
    } catch {
    } finally {
      isLoading.value = false
    }
  },
  { immediate: true }
)

onBeforeMount(() => {
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+t`,
    'Go to new taxon name task',
    'Browse OTU'
  )
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+m`,
    'Go to new type specimen',
    'Browse OTU'
  )
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+e`,
    'Go to comprehensive specimen digitization',
    'Browse OTU'
  )
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+b`,
    'Go to browse taxon names',
    'Browse OTU'
  )
})

function switchBrowse() {
  browseTaxonRef.value.redirect()
}

function switchNewTaxonName() {
  window.open(
    `${RouteNames.NewTaxonName}?taxon_name_id=${props.otu.taxon_name_id}`,
    '_self'
  )
}

function switchTypeMaterial() {
  window.open(
    `${RouteNames.TypeMaterial}?taxon_name_id=${props.otu.taxon_name_id}`,
    '_self'
  )
}

function switchComprehensive() {
  window.open(
    `${RouteNames.DigitizeTask}?taxon_name_id=${props.otu.taxon_name_id}`,
    '_self'
  )
}

function showForRanks(title) {
  const componentSection = Object.values(PANEL_COMPONENTS).find(
    (item) => item.title === title
  )

  if (!componentSection) return true

  const { rankGroup } = componentSection

  return rankGroup
    ? taxonName.value
      ? ShowForThisGroup(rankGroup, taxonName.value)
      : componentSection.otu
    : true
}

function openValid() {
  window.open(
    `${RouteNames.BrowseOtu}?taxon_name_id=${taxonName.value.cached_valid_taxon_name_id}`
  )
}
</script>

<style lang="scss" scoped>
.dropdown {
  display: none;
  position: absolute;
  padding: 12px;
  z-index: 200;
}

.dropdown-otu:hover {
  .dropdown {
    display: block;
  }
}
</style>

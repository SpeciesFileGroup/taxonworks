<template>
  <NavBar :class="{ 'feedback-warning': isInvalid }">
    <div>
      <ul
        v-if="navigation"
        class="breadcrumb_list"
      >
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
      <div class="horizontal-left-content middle gap-small">
        <h2 v-html="otu.object_tag" />
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
        <button
          v-if="isInvalid"
          v-help.section.header.validButton
          class="button button-default normal-input"
          @click="openValid"
        >
          Browse current OTU
        </button>
      </div>
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
import platformKey from '@/helpers/getPlatformKey.js'
import ShowForThisGroup from '@/tasks/nomenclature/new_taxon_name/helpers/showForThisGroup.js'
import NavBar from '@/components/layout/NavBar.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator'
import RadialObject from '@/components/radials/navigation/radial.vue'
import QuickForms from '@/components/radials/object/radial.vue'
import BrowseTaxon from '@/components/taxon_names/browseTaxon.vue'

const props = defineProps({
  otu: {
    type: Object,
    required: true
  },

  menu: {
    type: Array,
    required: true
  }
})

const otuStore = useOtuStore()
const browseTaxonRef = ref(null)
const navigation = ref()

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
  (newVal) => {
    Otu.breadcrumbs(newVal.id).then(({ body }) => {
      navigation.value = body
    })
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

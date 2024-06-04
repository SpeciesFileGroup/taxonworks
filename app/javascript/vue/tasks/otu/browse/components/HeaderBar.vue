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
            :href="`/tasks/otus/browse/${item[0].id}`"
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
                <a :href="`/tasks/otus/browse/${parent.id}`">{{
                  parent.object_label
                }}</a>
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
        <quick-forms :global-id="otu.global_id" />
        <radial-annotator
          :global-id="otu.global_id"
          type="annotations"
        />
        <radial-object
          :global-id="otu.global_id"
          type="annotations"
        />
        <browse-taxon
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
              >{{ item }}</a
            >
          </li>
        </template>
      </ul>
    </div>
  </NavBar>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator'
import RadialObject from '@/components/radials/navigation/radial.vue'
import QuickForms from '@/components/radials/object/radial.vue'
import BrowseTaxon from '@/components/taxon_names/browseTaxon.vue'
import platformKey from '@/helpers/getPlatformKey.js'
import ShowForThisGroup from '@/tasks/nomenclature/new_taxon_name/helpers/showForThisGroup.js'
import componentNames from '../const/componentNames.js'
import NavBar from '@/components/layout/NavBar.vue'
import useHotkey from 'vue3-hotkey'
import { GetterNames } from '../store/getters/getters'
import { RouteNames } from '@/routes/routes'
import { Otu } from '@/routes/endpoints'
import { ref, computed, watch, onBeforeMount } from 'vue'
import { useStore } from 'vuex'

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

const store = useStore()

const browseTaxonRef = ref(null)
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

const taxonName = computed(() => store.getters[GetterNames.GetTaxonName])
const isInvalid = computed(
  () => taxonName.value && !taxonName.value.cached_is_valid
)

const navigation = ref()

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
    'Go to browse nomenclature',
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

function showForRanks(section) {
  const componentSection = Object.values(componentNames).find(
    (item) => item.title === section
  )
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
.header-bar {
  margin-left: -15px;
  margin-right: -15px;
}
.container {
  margin: 0 auto;
  width: 1240px;
}

.dropdown {
  display: none;
  position: absolute;
  padding: 12px;
}

.dropdown-otu:hover {
  .dropdown {
    display: block;
  }
}
</style>

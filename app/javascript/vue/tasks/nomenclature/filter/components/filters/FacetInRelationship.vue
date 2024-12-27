<template>
  <FacetContainer>
    <h3>In relationship</h3>
    <VSwitch
      class="separate-bottom"
      :options="Object.values(OPTIONS)"
      v-model="view"
    />
    <div class="separate-top">
      <TreeDisplay
        v-if="view == OPTIONS.all"
        @close="view = OPTIONS.common"
        :object-lists="mergeLists"
        modal-title="Relationships"
        display="name"
        @selected="addRelationship"
      />
      <ul
        v-if="view == OPTIONS.common"
        class="no_bullets"
      >
        <template
          v-for="(item, key) in mergeLists.common"
          :key="key"
        >
          <li v-if="!filterAlreadyPicked(item.type)">
            <label>
              <input
                :value="key"
                @click="addRelationship(item)"
                type="radio"
              />
              {{ item.name }}
            </label>
          </li>
        </template>
      </ul>
      <VAutocomplete
        v-if="view == OPTIONS.advanced"
        url=""
        :array-list="
          Object.keys(mergeLists.all).map((key) => mergeLists.all[key])
        "
        label="name"
        clear-after
        min="3"
        time="0"
        @get-item="addRelationship"
        placeholder="Search"
        event-send="autocompleteRelationshipSelected"
        param="term"
      />
    </div>
    <DisplayList
      label="name"
      set-key="type"
      :delete-warning="false"
      soft-delete
      :list="relationshipSelected"
      @delete="removeItem"
    />
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import VSwitch from '@/components/ui/VSwitch'
import TreeDisplay from '../treeDisplay'
import VAutocomplete from '@/components/ui/Autocomplete'
import DisplayList from '@/components/displayList.vue'
import { URLParamsToJSON } from '@/helpers/url/parse.js'
import { TaxonNameRelationship } from '@/routes/endpoints'
import { computed, onMounted, ref, watch } from 'vue'

const OPTIONS = {
  common: 'common',
  advanced: 'advanced',
  all: 'all'
}

const params = defineModel()
const view = ref(OPTIONS.common)
const relationshipsList = ref({})
const relationshipSelected = ref([])
const mergeLists = ref({})
const display = ref('subject_status_tag')

const nomenclatureCode = computed(
  () => params.value.nomenclature_code?.toLowerCase()
)

watch(params, (newVal) => {
  if (!newVal.taxon_name_relationship_type?.length) {
    relationshipSelected.value = []
  }
})

watch(relationshipSelected,
  (newVal) => {
    params.value.taxon_name_relationship_type = newVal.map(
      (relationship) => relationship.type
    )
  },
  { deep: true }
)

watch(nomenclatureCode, (newVal) => {
  // newVal == undefined means 'any code'
  if (!newVal || relationshipsList.value[newVal]) {
    merge()
  }
})

onMounted(() => {
  TaxonNameRelationship.types().then((response) => {
    relationshipsList.value = response.body
    merge()

    const params = URLParamsToJSON(location.href)
    if (params.taxon_name_relationship_type) {
      params.taxon_name_relationship_type.forEach((type) => {
        const data = mergeLists.value.all[type]
        data.type = type
        data.name = mergeLists.value.all[type][display.value]
        addRelationship(data)
      })
    }
  })
})

function merge() {
  const relationships = JSON.parse(
    JSON.stringify(relationshipsList.value)
  )
  const newList = {
    all: {},
    common: {},
    tree: {}
  }
  const nomenclatureCodes = nomenclatureCode.value
    ? [nomenclatureCode.value]
    : Object.keys(relationships)

  nomenclatureCodes.forEach((key) => {
    newList.all = Object.assign(newList.all, relationships[key].all)
    newList.tree = Object.assign(newList.tree, relationships[key].tree)
    for (const keyType in relationships[key].common) {
      relationships[key].common[
        keyType
      ].name =
        `${relationships[key].common[keyType][display.value]} (${key})`
      relationships[key].common[keyType].type = keyType
    }
    newList.common = Object.assign(
      newList.common,
      relationships[key].common
    )
  })
  getTreeList(newList.tree, newList.all)
  addName(newList.all)
  addType(newList.all)
  mergeLists.value = newList
}

function getTreeList(list, ranksList) {
  for (const key in list) {
    if (key in ranksList) {
      Object.defineProperty(list[key], 'type', {
        writable: true,
        value: key
      })
      Object.defineProperty(list[key], 'name', {
        writable: true,
        value: ranksList[key][display.value]
      })
    }
    getTreeList(list[key], ranksList)
  }
}

function removeItem(relationship) {
  relationshipSelected.value.splice(
    relationshipSelected.value.findIndex(
      (item) => item.type === relationship.type
    ),
    1
  )
}

function addRelationship(item) {
  relationshipSelected.value.push(item)
  view.value = OPTIONS.common
}

function filterAlreadyPicked(type) {
  return relationshipSelected.value.find((item) => item.type === type)
}

function addName(list) {
  for (const key in list) {
    Object.defineProperty(
      list[key], 'name', { writable: true, value: list[key][display.value] }
    )
  }
}

function addType(list) {
  for (const key in list) {
    Object.defineProperty(
      list[key], 'type', { writable: true, value: key }
    )
  }
}
</script>

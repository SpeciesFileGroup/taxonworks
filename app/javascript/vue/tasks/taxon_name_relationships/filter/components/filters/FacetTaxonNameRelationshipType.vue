<template>
  <FacetContainer>
    <h3>Relationship type</h3>

    <VSwitch
      class="margin-medium-bottom"
      :options="Object.values(OPTIONS)"
      v-model="view"
    />
    <label
      title="Subclasses of selected items will be added automatically. Disabling this won’t remove any that were already added."
    >
      <input
        type="checkbox"
        v-model="setIncludeSubclasses"
      />
      Add subclasses
    </label>
    <div class="margin-medium-top">
      <TreeDisplay
        v-if="view == OPTIONS.all"
        :object-lists="mergeLists"
        modal-title="Relationships"
        display="name"
        @close="view = OPTIONS.common"
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
        :array-list="Object.values(mergeLists.all)"
        label="name"
        clear-after
        min="3"
        time="0"
        placeholder="Search"
        event-send="autocompleteRelationshipSelected"
        param="term"
        @get-item="addRelationship"
      />
    </div>

    <table
      v-if="relationshipsSelected.length"
      class="margin-medium-top"
    >
      <thead>
        <tr>
          <th>Relationship</th>
          <th />
          <th class="w-2" />
        </tr>
      </thead>
      <tbody>
        <RowItem
          v-for="(relationship, index) in relationshipsSelected"
          :key="index"
          class="list-complete-item"
          :item="relationship"
          @remove="() => removeItem(index)"
        />
      </tbody>
    </table>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import VSwitch from '@/components/ui/VSwitch'
import TreeDisplay from '@/tasks/nomenclature/filter/components/treeDisplay.vue'
import VAutocomplete from '@/components/ui/Autocomplete'
import RowItem from '@/tasks/nomenclature/filter/components/RowItem.vue'
import { URLParamsToJSON } from '@/helpers/url/parse.js'
import { TaxonNameRelationship } from '@/routes/endpoints'
import { computed, onMounted, ref, watch } from 'vue'
import { getUnique } from '@/helpers'

const OPTIONS = {
  common: 'common',
  advanced: 'advanced',
  all: 'all'
}

const params = defineModel({
  type: Object,
  required: true
})
params.value.taxon_name_relationship_type = []

const view = ref(OPTIONS.common)
const relationshipsList = ref({})
const relationshipsSelected = ref([])
const mergeLists = ref({})
const display = ref('subject_status_tag')
const includeSubclasses = ref(false)

const nomenclatureCode = computed(() =>
  params.value.nomenclature_code?.toLowerCase()
)

const setIncludeSubclasses = computed({
  get: () => includeSubclasses.value,
  set: (value) => {
    if (value) {
      const list = []

      relationshipsSelected.value.forEach((item) => {
        const items = Object.values(mergeLists.value.all).filter((r) =>
          r.type.includes(item.type)
        )

        list.push(...items)
      })

      relationshipsSelected.value = getUnique(list, 'type')
    }
  }
})

watch(params, (newVal) => {
  if (!newVal.taxon_name_relationship_type?.length) {
    relationshipsSelected.value = []
  }
})

watch(
  relationshipsSelected,
  (newVal) => {
    params.value.taxon_name_relationship_type = newVal.map((r) => r.type)
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

    const queryParams = URLParamsToJSON(location.href)
    queryParams.taxon_name_relationship_type?.forEach((relationship) => {
      const data = mergeLists.value.all[relationship]
      data.type = relationship
      data.name = mergeLists.value.all[relationship][display.value]
      addRelationship(data)
    })
  })
})

function merge() {
  const relationships = JSON.parse(JSON.stringify(relationshipsList.value))
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
      relationships[key].common[keyType].name = `${
        relationships[key].common[keyType][display.value]
      } (${key})`
      relationships[key].common[keyType].type = keyType
    }
    newList.common = Object.assign(newList.common, relationships[key].common)
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

function removeItem(index) {
  relationshipsSelected.value.splice(index, 1)
}

function addRelationship(item) {
  if (includeSubclasses.value) {
    const items = Object.values(mergeLists.value.all).filter((r) =>
      r.type.includes(item.type)
    )

    relationshipsSelected.value.push(...items)
  } else {
    relationshipsSelected.value.push(item)
  }
  view.value = OPTIONS.common
}

function filterAlreadyPicked(type) {
  return relationshipsSelected.value.find((item) => item.type === type)
}

function addName(list) {
  for (const key in list) {
    Object.defineProperty(list[key], 'name', {
      writable: true,
      value: list[key][display.value]
    })
  }
}

function addType(list) {
  for (const key in list) {
    Object.defineProperty(list[key], 'type', { writable: true, value: key })
  }
}
</script>

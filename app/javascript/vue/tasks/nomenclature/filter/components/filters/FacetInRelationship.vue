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

    <table
      v-if="relationshipSelected.length"
      class="vue-table"
    >
      <thead>
        <tr>
          <th>Relationship</th>
          <th />
          <th />
        </tr>
      </thead>
      <transition-group
        name="list-complete"
        tag="tbody"
      >
        <template
          v-for="(relationship, index) in relationshipSelected"
          :key="index"
        >
          <RowItem
            class="list-complete-item"
            :item="relationship"
            v-model="relationship.subject_object"
            :options="{
              Subject: SUBJECT_OBJECT.subject,
              Object: SUBJECT_OBJECT.object,
              Either: SUBJECT_OBJECT.either
            }"
            @remove="() => removeItem(index)"
          />
        </template>
      </transition-group>
    </table>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import VSwitch from '@/components/ui/VSwitch'
import TreeDisplay from '../treeDisplay'
import VAutocomplete from '@/components/ui/Autocomplete'
import RowItem from '../RowItem.vue'
import { URLParamsToJSON } from '@/helpers/url/parse.js'
import { TaxonNameRelationship } from '@/routes/endpoints'
import { computed, onMounted, ref, watch } from 'vue'

const OPTIONS = {
  common: 'common',
  advanced: 'advanced',
  all: 'all'
}

const SUBJECT_OBJECT = {
  subject: 'subject',
  object: 'object',
  either: 'either'
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
    params.value.taxon_name_relationship_type_subject = newVal
      .filter((r) => (r.subject_object == SUBJECT_OBJECT.subject))
      .map((r) => r.type)
    params.value.taxon_name_relationship_type_object = newVal
      .filter((r) => (r.subject_object == SUBJECT_OBJECT.object))
      .map((r) => r.type)
    params.value.taxon_name_relationship_type_either = newVal
      .filter((r) => (r.subject_object == SUBJECT_OBJECT.either))
      .map((r) => r.type)
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
    const relationshipLists = {
      [SUBJECT_OBJECT.subject]: queryParams.taxon_name_relationship_type_subject || [],
      [SUBJECT_OBJECT.object]: queryParams.taxon_name_relationship_type_object || [],
      [SUBJECT_OBJECT.either]: queryParams.taxon_name_relationship_type_either || []
    }
    Object.keys(relationshipLists).forEach((subject_object) => {
      const relationshipsList = relationshipLists[subject_object]
      relationshipsList.forEach((relationship) => {
        const data = mergeLists.value.all[relationship]
        data.type = relationship
        data.name = mergeLists.value.all[relationship][display.value]
        addRelationship(data, subject_object)
      })
    })
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

function removeItem(index) {
  relationshipSelected.value.splice(index, 1)
}

function addRelationship(item, subject_object = SUBJECT_OBJECT.either) {
  item.subject_object = subject_object
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

<style scoped>

</style>

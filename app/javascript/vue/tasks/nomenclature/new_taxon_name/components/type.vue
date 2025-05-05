<template>
  <BlockLayout
    anchor="type"
    :warning="checkValidation"
    :spinner="!taxon.id"
    v-help.section.type.container
  >
    <template #header>
      <h3>Type</h3>
    </template>
    <template #body>
      <div v-if="!taxonRelation">
        <div
          v-if="editType"
          class="horizontal-left-content"
        >
          <span>
            <span v-html="relationshipsCreated[0].object_tag" />
            <a
              v-html="relationshipsCreated[0].subject_object_tag"
              :href="`/tasks/nomenclature/browse?taxon_name_id=${relationshipsCreated[0].subject_taxon_name_id}`"
            />
          </span>
          <span
            class="button circle-button btn-undo button-default"
            @click="editType = undefined"
          />
        </div>
        <quick-taxon-name
          v-if="
            !showForThisGroup(
              ['SpeciesGroup', 'SpeciesAndInfraspeciesGroup'],
              taxon
            ) &&
            (!relationshipsCreated.length || editType)
          "
          :group="childOfParent[rankGroup.toLowerCase()]"
          @get-item="addTaxonType"
        />
        <template
          v-if="
            showForThisGroup(
              ['SpeciesGroup', 'SpeciesAndInfraspeciesGroup'],
              taxon
            )
          "
        >
          <ul class="no_bullets context-menu">
            <li>
              <a :href="`${RouteNames.TypeMaterial}?taxon_name_id=${taxon.id}`">
                Quick
              </a>
            </li>
            <li>
              <a :href="`${RouteNames.DigitizeTask}?taxon_name_id=${taxon.id}`">
                Comprehensive
              </a>
            </li>
          </ul>
          <ul class="table-entrys-list">
            <li
              class="flex-separate list-complete-item"
              v-for="typeSpecimen in typeMaterialList"
              :key="typeSpecimen.id"
            >
              <a
                :href="`${RouteNames.TypeMaterial}?taxon_name_id=${taxon.id}&type_material_id=${typeSpecimen.id}`"
                v-html="typeSpecimen.object_tag"
              />
              <a
                :href="`${RouteNames.DigitizeTask}?collection_object_id=${typeSpecimen.collection_object_id}`"
                >Open comprehensive</a
              >
            </li>
          </ul>
        </template>
      </div>
      <div v-else>
        <VSwitch
          :options="Object.values(TAB)"
          v-model="view"
        />
        <TreeDisplay
          v-if="view === TAB.showAll"
          :parent="parent"
          :list="objectLists.tree"
          :taxon-rank="taxon.rank_string"
          valid-property="valid_object_ranks"
          display-name="subject_status_tag"
          @selected="addEntry"
          @close="view = TAB.common"
        />

        <p class="inline">
          <span
            v-html="
              taxonRelation.hasOwnProperty('label_html')
                ? taxonRelation.label_html
                : taxonRelation.object_tag
            "
          />
          <VBtn
            circle
            color="primary"
            title="Undo"
            @click="taxonRelation = undefined"
          >
            <VIcon
              name="undo"
              small
            />
          </VBtn>
        </p>

        <ListCommon
          v-if="view === TAB.common"
          class="separate-top"
          filter
          display="subject_status_tag"
          :object-lists="objectLists.common"
          :list-created="relationshipsCreated"
          @add-entry="addEntry"
        />
      </div>
      <ListEntrys
        :list="relationshipsCreated"
        :display="[
          {
            link: '/tasks/nomenclature/browse?taxon_name_id=',
            label: 'subject_object_tag',
            param: 'subject_taxon_name_id'
          },
          'subject_status_tag',
          'object_object_tag'
        ]"
        edit
        @delete="removeType"
        @edit="setEdit"
        @update="loadTaxonRelationships"
        @add-citation="setType"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { computed, ref, watch, onMounted } from 'vue'
import { useStore } from 'vuex'
import { RouteNames } from '@/routes/routes.js'
import { ActionNames } from '../store/actions/actions'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { TypeMaterial } from '@/routes/endpoints'
import TreeDisplay from './treeDisplay.vue'
import ListEntrys from './listEntrys.vue'
import ListCommon from './commonList.vue'
import getRankGroup from '../helpers/getRankGroup'
import childOfParent from '../helpers/childOfParent'
import QuickTaxonName from './quickTaxonName'
import VSwitch from '@/components/ui/VSwitch.vue'
import BlockLayout from '@/components/layout/BlockLayout'
import platformKey from '@/helpers/getPlatformKey.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import showForThisGroup from '../helpers/showForThisGroup'
import { useHotkey } from '@/composables'

const TAB = {
  common: 'Common',
  showAll: 'Show all'
}

const store = useStore()

const shortcuts = ref([
  {
    keys: [platformKey(), 'm'],
    preventDefault: true,
    handler() {
      switchTypeMaterial()
    }
  },
  {
    keys: [platformKey(), 'e'],
    preventDefault: true,
    handler() {
      switchComprehensive()
    }
  }
])

useHotkey(shortcuts.value)

const treeList = computed(() => store.getters[GetterNames.GetRelationshipList])
const taxon = computed(() => store.getters[GetterNames.GetTaxon])
const parent = computed(() => store.getters[GetterNames.GetParent])
const rankGroup = computed(() =>
  getRankGroup(store.getters[GetterNames.GetTaxon].rank_string)
)

const relationshipsCreated = computed(() =>
  store.getters[GetterNames.GetTaxonRelationshipList].filter(
    ({ type }) => type.split('::')[1] === 'Typification'
  )
)

const softValidation = computed(
  () => store.getters[GetterNames.GetSoftValidation].taxonRelationshipList.list
)

const checkValidation = computed(() =>
  softValidation.value.some((item) =>
    relationshipsCreated.value.some(
      (created) => created.id === item.instance.id
    )
  )
)

const taxonRelation = computed({
  get() {
    return store.getters[GetterNames.GetTaxonType]
  },
  set(value) {
    store.commit(MutationNames.SetTaxonType, value)
  }
})

const objectLists = ref(makeLists())
const editType = ref()
const typeMaterialList = ref([])
const view = ref(TAB.common)

watch(
  parent,
  (newVal) => {
    if (newVal == null) return true
    refresh()
  },
  { immediate: true }
)

watch(
  taxon,
  (newVal, oldVal) => {
    if (newVal.id && (!oldVal || newVal.id !== oldVal.id)) {
      TypeMaterial.where({ protonym_id: newVal.id }).then(({ body }) => {
        typeMaterialList.value = body
      })
    }
  },
  {
    immediate: true,
    deep: true
  }
)

onMounted(() => {
  TW.workbench.keyboard.createLegend(
    platformKey() + '+' + 'm',
    'Go to new type material',
    'New taxon name'
  )
  TW.workbench.keyboard.createLegend(
    platformKey() + '+' + 'c',
    'Go to comprehensive specimen digitization',
    'New taxon name'
  )
})

function setEdit(relationship) {
  editType.value = relationship
  addTaxonType({
    id: relationship.subject_taxon_name_id,
    label_html: relationship.object_tag
  })
}

function loadTaxonRelationships() {
  store.dispatch(ActionNames.LoadTaxonRelationships, taxon.value.id)
}

function setType(item) {
  store.dispatch(ActionNames.UpdateTaxonRelationship, item)
}

function removeType(item) {
  store.dispatch(ActionNames.RemoveTaxonRelationship, item)
  store.commit(MutationNames.SetTaxon, {
    ...taxon.value,
    type_taxon_name_relationship: undefined
  })
}

function refresh() {
  objectLists.value.tree = filterList(
    addType(Object.assign({}, treeList.value.typification.all)),
    rankGroup.value
  )
  objectLists.value.common = filterList(
    addType(Object.assign({}, treeList.value.typification.common)),
    rankGroup.value
  )
}

function makeLists() {
  return {
    tree: undefined,
    common: undefined
  }
}

function addTaxonType(taxon) {
  taxonRelation.value = taxon
  if (rankGroup.value == 'Family') {
    addEntry(objectLists.value.tree[Object.keys(objectLists.value.tree)[0]])
  }
}

function addEntry(item) {
  const saveRequest = editType.value
    ? store.dispatch(ActionNames.UpdateTaxonType, {
        ...item,
        id: editType.value.id
      })
    : store.dispatch(ActionNames.AddTaxonType, item)

  saveRequest.then(() => {
    store.commit(MutationNames.UpdateLastChange)
    editType.value = undefined
  })
}

function filterList(list, filter) {
  const tmp = {}

  for (const key in list) {
    if (key.split('::')[2] === filter) {
      tmp[key] = list[key]
    }
  }
  return tmp
}

function addType(list) {
  for (const key in list) {
    list[key].type = key
  }
  return list
}

function switchTypeMaterial() {
  window.open(
    `${RouteNames.TypeMaterial}?taxon_name_id=${taxon.value.id}`,
    '_self'
  )
}

function switchComprehensive() {
  window.open(
    `${RouteNames.DigitizeTask}?taxon_name_id=${taxon.value.id}`,
    '_self'
  )
}
</script>

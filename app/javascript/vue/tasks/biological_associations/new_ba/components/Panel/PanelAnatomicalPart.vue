<template>
  <BlockLayout :warning="!anatomicalPart">
    <template #header>
      <div class="horizontal-left-content middle gap-small">
        <h3>Anatomical part</h3>
      </div>
    </template>
    <template #body>
      <div v-if="parentIsAnatomicalPart">
        <span class="subtle"> {{ title }} is already an anatomical part. </span>
      </div>

      <div v-else-if="!parentObject">
        <span class="subtle"> Select a {{ title.toLowerCase() }} first. </span>
      </div>

      <div v-else>
        <div
          v-if="anatomicalPart"
          class="flex-row middle flex-separate"
        >
          <span>
            <span v-html="anatomicalPart.object_tag || displayLabel" />
            <span
              v-if="!anatomicalPart.id"
              class="subtle margin-small-left"
            >
              (will be created on save)
            </span>
          </span>
          <VBtn
            class="margin-small-left"
            color="primary"
            circle
            @click="unsetAnatomicalPart"
          >
            <VIcon
              name="trash"
              x-small
            />
          </VBtn>
        </div>

        <div v-else>
          <VSwitch
            :options="TAB_OPTIONS"
            v-model="currentTab"
            class="margin-small-bottom"
          />

          <SmartSelector
            v-if="currentTab === TAB_SEARCH"
            model="anatomical_parts"
            @selected="selectExistingAnatomicalPart"
          />

          <div v-else>
            <fieldset>
              <legend>Name or URI</legend>
              <div class="margin-medium-bottom">
                <input
                  class="normal-input full_width"
                  type="text"
                  v-model="formData.name"
                  placeholder="Name"
                />
              </div>

              or

              <fieldset class="margin-medium-top">
                <legend>Search ontologies for terms</legend>
                <div class="margin-medium-bottom margin-small-top">
                  Ontology search sources:
                </div>
                <div>
                  <div
                    v-for="pref in ontologyPreferences"
                    :key="pref.oid"
                  >
                    <label>
                      <input
                        type="checkbox"
                        :value="pref.oid"
                        v-model="selectedOntologies"
                        class="margin-medium-left"
                      />
                      <span
                        :title="pref.oid"
                        class="padding-xsmall-left"
                      >
                        {{ pref.title }}
                      </span>
                    </label>
                  </div>
                </div>
                <VAutocomplete
                  url="/anatomical_parts/ontology_autocomplete"
                  :add-params="{ ontologies: selectedOntologies }"
                  label="ontology_label"
                  min="3"
                  clear-after
                  placeholder="Search for an ontology term, e.g. femur"
                  param="term"
                  class="margin-medium-top"
                  @select="setOntologyTerm"
                />
              </fieldset>

              <div class="margin-medium-top flex-row gap-medium">
                <input
                  class="normal-input"
                  style="flex-grow: 1"
                  type="text"
                  v-model="formData.uri_label"
                  :title="formData.uri_label"
                  placeholder="URI label"
                />
                <input
                  class="normal-input"
                  style="flex-grow: 2"
                  type="text"
                  v-model="formData.uri"
                  :title="formData.uri"
                  placeholder="URI"
                />
              </div>
            </fieldset>
            <template v-if="objectType === COLLECTION_OBJECT">
              <label class="margin-medium-top margin-medium-bottom">
                <input
                  type="checkbox"
                  v-model="formData.is_material"
                />
                Is material
              </label>

              <PreparationType v-model="formData" />
            </template>

            <div class="horizontal-left-content gap-small margin-medium-top">
              <VBtn
                :disabled="!isFormValid"
                color="primary"
                medium
                @click="setNewAnatomicalPart"
              >
                Set
              </VBtn>

              <VBtn
                color="primary"
                medium
                @click="resetForm"
              >
                Reset
              </VBtn>
            </div>
          </div>
        </div>
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { AnatomicalPart } from '@/routes/endpoints'
import { COLLECTION_OBJECT } from '@/constants'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VSwitch from '@/components/ui/VSwitch.vue'
import PreparationType from '@/components/radials/object/components/origin_relationship/create/anatomical_parts/components/PreparationType.vue'

const props = defineProps({
  parentObject: {
    type: Object,
    default: null
  },

  title: {
    type: String,
    default: 'Anatomical part'
  }
})

const anatomicalPart = defineModel({
  type: Object,
  default: null
})

const objectType = computed(() => props.parentObject?.base_class)

const parentObject = computed(() => props.parentObject)

const parentIsAnatomicalPart = computed(
  () => props.parentObject?.base_class === 'AnatomicalPart'
)

const TAB_SEARCH = 'Search'
const TAB_NEW = 'New'
const TAB_OPTIONS = [TAB_SEARCH, TAB_NEW]
const currentTab = ref(TAB_SEARCH)
const ontologyPreferences = ref([])
const selectedOntologies = ref([])

const formData = ref(makeAnatomicalPart())

const isFormValid = computed(
  () => formData.value.name || (formData.value.uri && formData.value.uri_label)
)

const displayLabel = computed(() => {
  const ap = anatomicalPart.value
  if (!ap) return ''
  if (ap.name) return ap.name
  if (ap.uri_label) return `${ap.uri_label} (${ap.uri})`
  return ''
})

function makeAnatomicalPart(data = {}) {
  return {
    id: data.id || null,
    name: data.name || '',
    uri: data.uri || '',
    uri_label: data.uri_label || '',
    is_material: data.is_material ?? undefined,
    preparation_type_id: data.preparation_type_id || undefined,
    object_tag: data.object_tag || null
  }
}

function selectExistingAnatomicalPart(item) {
  anatomicalPart.value = makeAnatomicalPart({
    id: item.id,
    object_tag: item.object_tag
  })
}

function setOntologyTerm(value) {
  formData.value.uri_label = value.label
  formData.value.uri = value.iri
}

function setNewAnatomicalPart() {
  anatomicalPart.value = makeAnatomicalPart(formData.value)
  currentTab.value = TAB_SEARCH
}

function unsetAnatomicalPart() {
  anatomicalPart.value = null
}

function resetForm() {
  const isMaterial = defaultIsMaterial()
  formData.value = makeAnatomicalPart({ is_material: isMaterial })
}

function defaultIsMaterial() {
  const baseClass = props.parentObject?.base_class
  if (baseClass === 'Otu' || baseClass === 'FieldOccurrence') return false
  if (baseClass === 'CollectionObject') return true
  return undefined
}

watch(
  () => props.parentObject,
  (newVal, oldVal) => {
    if (newVal !== oldVal) {
      anatomicalPart.value = null
    }

    if (newVal) {
      formData.value.is_material = defaultIsMaterial()
    }
  }
)

onMounted(() => {
  AnatomicalPart.ontologyPreferences()
    .then(({ body }) => {
      if (body.length > 0) {
        ontologyPreferences.value = body
      } else {
        ontologyPreferences.value = [
          { oid: 'uberon', title: 'Uber-anatomy ontology' }
        ]
      }
      selectedOntologies.value = ontologyPreferences.value.map(
        (pref) => pref.oid
      )
    })
    .catch(() => {})
})
</script>

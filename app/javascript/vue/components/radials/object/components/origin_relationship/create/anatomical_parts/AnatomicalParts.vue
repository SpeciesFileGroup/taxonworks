<template>
  <div>
    <VSpinner
      v-if="isLoading"
    />

    <div>
      <fieldset>
        <legend>Name or URI</legend>
        <div class="margin-large-bottom">
          <input
            class="normal-input"
            type="text"
            v-model="anatomicalPart.name"
            placeholder="Name"
          />
        </div>

        or

        <fieldset class="margin-large-top">
          <legend>Search ontologies for terms</legend>
          <div class="margin-medium-bottom margin-small-top">Ontology search sources:</div>
          <div>
            <div
              v-for="pref in ontologyPreferences"
              :key="pref.oid"
            >
              <input
                type="checkbox"
                :value="pref.oid"
                v-model="selectedOntologies"
                class="margin-medium-left"
              >
                <span :title="pref.oid" class="padding-xsmall-left">
                  {{ pref.title }}
                </span>
              </input>
            </div>
          </div>
          <Autocomplete
            url="/anatomical_parts/ontology_autocomplete"
            :add-params="{ ontologies: selectedOntologies }"
            label="ontology_label"
            min="3"
            clear-after
            placeholder="Search for an ontology term, e.g. femur"
            param="term"
            class="margin-large-top"
            @get-item="
              (value) => {
                anatomicalPart.uri_label = value.label
                anatomicalPart.uri = value.iri
            }"
          />
        </fieldset>


        <div class="margin-large-top flex-row gap-medium">
          <input
            class="normal-input input-width-smaller"
            type="text"
            v-model="anatomicalPart.uri_label"
            :title="anatomicalPart.uri_label"
            placeholder="URI label"
          />
          <input
            class="normal-input input-width-larger"
            type="text"
            v-model="anatomicalPart.uri"
            :title="anatomicalPart.uri"
            placeholder="URI"
          />
        </div>
      </fieldset>

      <input
        class="margin-large-top margin-large-bottom"
        type="checkbox"
        v-model="anatomicalPart.is_material"
      >
        Is material
      </input>

      <PreparationType
        v-model="anatomicalPart"
      />

      <div class="horizontal-left-content gap-small margin-large-top margin-large-bottom">
        <VBtn
          :disabled="!validAnatomicalPart"
          color="create"
          medium
          @click="save"
        >
          {{ anatomicalPart.id ? 'Update' : 'Create' }}
        </VBtn>

        <VBtn
          v-if="!anatomicalPart.id"
          color="primary"
          medium
          @click="() => (anatomicalPart = {})"
        >
          Reset
        </VBtn>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { AnatomicalPart } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import PreparationType from './components/PreparationType.vue'
import Autocomplete from '@/components/ui/Autocomplete.vue'
import { URLParamsToJSON } from '@/helpers'

const props = defineProps({
  objectId: {
    type: Number,
    required: false
  },

  objectType: {
    type: String,
    required: false
  },

  modalEdit: {
    type: Boolean,
    required: false
  },

  modalCreate: {
    type: Boolean,
    required: false
  }
})

const anatomicalPart = ref({})
const ontologyPreferences = ref([])
const selectedOntologies = ref([])
const isLoading = ref(false)

const emit = defineEmits(['originRelationshipCreated', 'anatomicalPartLoaded'])

const validAnatomicalPart = computed(() => {
  return anatomicalPart.value.name ||
    (anatomicalPart.value.uri && anatomicalPart.value.uri_label)
})

function save() {
  const payload = anatomicalPart.value.id ?
  { anatomical_part: anatomicalPart.value } :
  {
    anatomical_part: {
      ...anatomicalPart.value,
      inbound_origin_relationship_attributes: {
        old_object_id: props.objectId,
        old_object_type: props.objectType
      }
    }
  }

  const response = anatomicalPart.value.id
    ? AnatomicalPart.update(anatomicalPart.value.id, payload)
    : AnatomicalPart.create(payload)

  isLoading.value = true
  response
    .then(({ body }) => {
      if (anatomicalPart.value.id) {
        TW.workbench.alert.create('Anatomical part was successfully saved.', 'notice')
      } else {
        resetForm()
        emit('originRelationshipCreated', body.origin_relationship)
        TW.workbench.alert.create('Anatomical part and Origin relationship were successfully created.', 'notice')
      }
    })
    .catch(() => {})
    .finally(() => (isLoading.value = false))
}

function resetForm() {
  anatomicalPart.value = {}
}

onMounted(() => {
  const anatomicalPartId = URLParamsToJSON(location.href).anatomical_part_id
  if (anatomicalPartId && !props.modalEdit && !props.modalCreate) { // Edit task
    isLoading.value = true
    AnatomicalPart.find(anatomicalPartId)
      .then(({ body }) => {
        anatomicalPart.value = body.anatomical_part
        emit('anatomicalPartLoaded', anatomicalPart.value)
      })
      .catch(() => {})
      .finally(() => (isLoading.value = false))

  } else {
    if (props.objectType != 'AnatomicalPart') { // Create new part
      let is_material = true
      if (props.objectType == 'Otu' || props.objectType == 'FieldOccurrence') {
        is_material = false
      }

      anatomicalPart.value = {
      cached_otu_id: props.cachedOtuId,
      is_material
      }
    } else {
      isLoading.value = true
      AnatomicalPart.find(props.objectId)
        .then(({ body }) => {
          if (props.modalEdit) {
            anatomicalPart.value = body.anatomical_part
          } else { // # Create new part
            // cachedOtuId of the new anatomical part should be the same as the
            // origin if the origin is an anatomical part.
            anatomicalPart.value = {
              cached_otu_id: body.anatomical_part.cached_otu_id,
              is_material: body.anatomical_part.is_material
            }
          }
        })
        .catch(() => {})
        .finally(() => (isLoading.value = false))
    }
  }

  AnatomicalPart.ontologyPreferences()
    .then(({ body }) => {
      if (body.length > 0) {
        ontologyPreferences.value = body
      } else {
        ontologyPreferences.value = [{oid: 'uberon', title: 'Uber-anatomy ontology'}]
      }
      selectedOntologies.value = ontologyPreferences.value.map((pref) => pref.oid)
    })
    .catch(() => {})
})
</script>

<style scoped>
.input-width-larger {
  flex-grow: 2;
}

.input-width-smaller {
  flex-grow: 1;
}

.uri-inputs {
  display: flex;
  gap: 1em;
}

</style>
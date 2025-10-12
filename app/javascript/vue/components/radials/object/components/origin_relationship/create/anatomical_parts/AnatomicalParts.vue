<template>
  <div>
    <VSpinner
      v-if="isLoading"
    />

    <div>
      <fieldset>
        <legend>Name/URI</legend>
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
          <span>Ontology search sources:</span>
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
                <span :title="pref.oid">
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

      <div class="horizontal-left-content gap-small">
        <VBtn
          :disabled="!validAnatomicalPart"
          color="create"
          medium
          @click="save"
        >
          {{ anatomicalPart.id ? 'Update' : 'Create' }}
        </VBtn>

        <VBtn
          color="primary"
          medium
          @click="() => (anatomicalPart = {})"
        >
          New
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

const props = defineProps({
  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  }
})

const anatomicalPart = ref({})
const ontologyPreferences = ref([{oid: 'uberon', title: 'Uber-anatomy ontology'}])
const selectedOntologies = ref([])
const isLoading = ref(false)

const emit = defineEmits(['originRelationshipCreated'])

const validAnatomicalPart = computed(() => {
  return anatomicalPart.value.name ||
    (anatomicalPart.value.uri && anatomicalPart.value.uri_label)
})

function save() {
  const payload = {
    anatomical_part: {
      ...anatomicalPart.value,
      inbound_origin_relationship_attributes: {
        old_object_id: props.objectId,
        old_object_type: props.objectType
      }
    }
  }

  const response = anatomicalPart.id
    ? AnatomicalPart.update(anatomicalPart.id, payload)
    : AnatomicalPart.create(payload)

  isLoading.value = true
  response
    .then(({ body }) => {
      resetForm()
      if (anatomicalPart.id) {
        TW.workbench.alert.create('Anatomical part was successfully saved.', 'notice')
      } else {
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
  if (props.objectType != 'AnatomicalPart') {
    let is_material = true
    if (props.objectType == 'Otu' || props.objectType == 'FieldOccurrence') {
      is_material = false
    }

    anatomicalPart.value = {
     cached_otu_id: props.cachedOtuId,
     is_material
    }
  } else {
    // cachedOtuId of the new anatomical part should be the same as the origin
    // if the origin is an anatomical part.
    isLoading.value = true
    AnatomicalPart.find(props.objectId)
      .then(({ body }) => {
        anatomicalPart.value = {
          cached_otu_id: body.cached_otu_id,
          is_material: body.is_material
        }
      })
      .catch(() => {})
      .finally(() => (isLoading.value = false))

  }

  AnatomicalPart.ontologyPreferences()
    .then(({ body }) => {
      ontologyPreferences.value = body
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
<template>
  <div>
    <fieldset>
      <legend>Name or URI</legend>

      <div class="margin-large-bottom">
        <input
          v-model="anatomicalPart.name"
          class="normal-input"
          placeholder="Name"
          type="text"
        />
      </div>

      or

      <fieldset
        v-if="showOntologySearch"
        class="margin-large-top"
      >
        <legend>Search ontologies for terms</legend>
        <div class="margin-medium-bottom margin-small-top">
          Ontology search sources:
        </div>

        <div>
          <div
            v-for="pref in ontologyPreferences"
            :key="pref.oid"
          >
            <input
              v-model="selectedOntologies"
              class="margin-medium-left"
              :value="pref.oid"
              type="checkbox"
            />
            <span
              :title="pref.oid"
              class="padding-xsmall-left"
            >
              {{ pref.title }}
            </span>
          </div>
        </div>

        <Autocomplete
          class="margin-large-top"
          url="/anatomical_parts/ontology_autocomplete"
          :add-params="{ ontologies: selectedOntologies }"
          label="ontology_label"
          min="3"
          clear-after
          placeholder="Search for an ontology term, e.g. femur"
          param="term"
          @get-item="setOntologyTerm"
        />
      </fieldset>

      <div class="margin-large-top flex-row gap-medium">
        <input
          v-model="anatomicalPart.uri_label"
          :title="anatomicalPart.uri_label"
          class="normal-input input-width-smaller"
          placeholder="URI label"
          type="text"
        />
        <input
          v-model="anatomicalPart.uri"
          :title="anatomicalPart.uri"
          class="normal-input input-width-larger"
          placeholder="URI"
          type="text"
        />
      </div>
    </fieldset>

    <label v-if="includeIsMaterial">
      <input
        v-model="anatomicalPart.is_material"
        class="margin-large-top margin-large-bottom"
        type="checkbox"
      />
      Is material
    </label>

    <PreparationType
      v-model="anatomicalPart"
      :display="preparationTypeDisplay"
    />
  </div>
</template>

<script setup>
import { AnatomicalPart } from '@/routes/endpoints'
import Autocomplete from '@/components/ui/Autocomplete.vue'
import PreparationType from './PreparationType.vue'
import { onMounted, ref } from 'vue'

const anatomicalPart = defineModel({
  type: Object,
  required: true
})

defineProps({
  includeIsMaterial: {
    type: Boolean,
    default: true
  },

  showOntologySearch: {
    type: Boolean,
    default: true
  },

  preparationTypeDisplay: {
    type: String,
    default: 'radio',
    validator: (value) => ['radio', 'select'].includes(value)
  }
})

const ontologyPreferences = ref([])
const selectedOntologies = ref([])

function setOntologyTerm(value) {
  anatomicalPart.value.name = undefined
  anatomicalPart.value.uri_label = value.label
  anatomicalPart.value.uri = value.iri
}

onMounted(() => {
  AnatomicalPart.ontologyPreferences()
    .then(({ body }) => {
      ontologyPreferences.value = body.length
        ? body
        : [{ oid: 'uberon', title: 'Uber-anatomy ontology' }]
      selectedOntologies.value = ontologyPreferences.value.map((pref) => pref.oid)
    })
    .catch(() => {
      ontologyPreferences.value = [{ oid: 'uberon', title: 'Uber-anatomy ontology' }]
      selectedOntologies.value = ['uberon']
    })
})
</script>

<style scoped>
.input-width-larger {
  flex-grow: 2;
}

.input-width-smaller {
  flex-grow: 1;
}
</style>

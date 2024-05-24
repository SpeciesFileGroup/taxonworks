<template>
  <fieldset class="import_options">
    <legend>Convert</legend>

    <div class="field label-above">
      <label>
        Matrix name (left blank will provide a timestamped default)
        <input
          type="text"
          class="normal-input full_width"
          v-model="options.matrix_name"
        />
      </label>
    </div>

    <div
      v-for="(label, param) in BOOL_PARAMETERS"
      :key="param"
      class="field"
    >
      <label>
        <input
          type="checkbox"
          v-model="options[param]"
        />
        {{ label }}
      </label>
    </div>

    <div
      v-if="!showCitationOptions"
      @click="() => showCitationOptions = true"
    >
      <span class="link cursor-pointer">
        Show Citation options
      </span>
    </div>
    <CitationOptions
      v-else
      v-model:cite-otus="options.cite_otus"
      v-model:cite-descriptors="options.cite_descriptors"
      v-model:cite-observations="options.cite_observations"
      v-model:cite-matrix="options.cite_matrix"
      v-model:citation="options.citation"
    />

    <VBtn
      color="update"
      medium
      :disabled="!docChosen || loading"
      @click="emit('convert')"
      class="button"
    >
      Convert
    </VBtn>

    <span v-if="loading">
      <InlineSpinner  />
      Parsing nexus file...
    </span>

    <div v-if="matrixId">
      The new matrix
      <a
        :href="RouteNames.ObservationMatricesView + '/' + matrixId"
        target="_blank"
      >
        {{ matrixName }}
      </a>
      is being populated by a background job. The matrix will be empty until
      the import finishes; if the import fails the matrix will be deleted, in
      which case the link will no longer work.
    </div>
  </fieldset>
</template>

<script setup>
import { RouteNames } from '@/routes/routes'
import { ref } from 'vue'
import CitationOptions from './CitationOptions.vue'
import InlineSpinner from './InlineSpinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const BOOL_PARAMETERS = {
  match_otu_to_taxonomy_name: 'Match otus to db using taxonomy name',
  match_otu_to_name: 'Match otus to db using name',
  match_character_to_name:
    'Match characters to db using name (character states must match as well)'
}

const props = defineProps({
  docChosen: {
    type: Boolean,
    default: false
  },
  matrixId: {
    type: Number,
    default: null
  },
  matrixName: {
    type: String,
    default: null
  },
  loading: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['convert'])

const showCitationOptions = ref(false)

const options = defineModel()
options.value = {
  // Default values.
  matrix_name: '',
  match_otu_to_taxonomy_name: false,
  match_otu_to_name: false,
  match_character_to_name: false,
  cite_otus: false,
  cite_descriptors: false,
  cite_observations: false,
  cite_matrix: false,
  citation: {}
}

</script>

<style lang="scss" scoped>
.import_options {
  width: 600px;
  margin-bottom: 2em;
}
.button {
  margin-top: 1em;
  margin-bottom: 1em;
  margin-right: 1.5em;
}
</style>
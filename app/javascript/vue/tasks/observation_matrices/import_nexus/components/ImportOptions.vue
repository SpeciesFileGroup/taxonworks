<template>
  <fieldset class="import_options">
    <legend>Convert</legend>

    <div class="field label-above">
      <label>Matrix name (left blank will provide a timestamped default)</label>
      <input
        type="text"
        class="normal-input full_width"
        v-model="options.matrix_name"
      />
    </div>

    <div class="field">
      <label>match otus to db using taxonomy name</label>
      <input
        type="checkbox"
        v-model="options.match_otu_to_taxonomy_name"
      />
    </div>

    <div class="field">
      <label>match otus to db using name</label>
      <input
        type="checkbox"
        v-model="options.match_otu_to_name"
      />
    </div>

    <div class="field">
      <label>
        match characters to db using name (character states must match as well)
      </label>
      <input
        type="checkbox"
        v-model="options.match_character_to_name"
      />
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

    <div>
      <VBtn
        color="update"
        medium
        :disabled="!docChosen"
        @click="emit('convert')"
        class="button"
      >
        Convert
      </VBtn>
    </div>

    <div v-if="matrixId">
      The new matrix
      <a
        :href="RouteNames.ObservationMatricesView + '/' + matrixId"
        target="_blank"
      >
        {{ matrixName }}
      </a>
      is being populated by a background job. The matrix will be empty until
      the import finishes; if the import fails the matrix will be deleted.
    </div>
  </fieldset>
</template>

<script setup>
import { RouteNames } from '@/routes/routes'
import { ref } from 'vue'
import CitationOptions from './CitationOptions.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

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
}
</style>
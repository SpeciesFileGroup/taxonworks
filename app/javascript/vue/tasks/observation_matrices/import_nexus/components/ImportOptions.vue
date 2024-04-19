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
        match characters to db using name (matches character states as well)
      </label>
      <input
        type="checkbox"
        v-model="options.match_character_to_name"
      />
    </div>

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
      <!--TODO: Give a message on how to find the new matrix/progress-->
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

const options = defineModel()
options.value = {
  // Default values.
  matrix_name: '',
  match_otu_to_taxonomy_name: false,
  match_otu_to_name: false,
  match_character_to_name: false
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
<template>
  <fieldset>
    <legend>Citation options</legend>
    <FormCitation
      v-model="citation"
      class="citation_form"
    />

    <div class="field">
      <label>
        <input
          type="checkbox"
          v-model="citeMatrix"
        />
        cite matrix with selected source
      </label>
    </div>

    <div class="field">
      <label>
        <input
          type="checkbox"
          v-model="citeOtus"
        />
        cite new otus with selected source
      </label>
    </div>

    <div class="field">
      <label>
        <input
          type="checkbox"
          v-model="citeDescriptors"
        />
        cite new descriptors with selected source
      </label>
    </div>

    <div class="field">
      <label>
        <input
          type="checkbox"
          v-model="citeObservations"
        />
        cite new observations with selected source
      </label>
    </div>
  </fieldset>
</template>

<script setup>
import FormCitation from '@/components/Form/FormCitation.vue'

const citeOtus = defineModel('citeOtus')
const citeDescriptors = defineModel('citeDescriptors')
const citeObservations = defineModel('citeObservations')
const citeMatrix = defineModel('citeMatrix')
const citation = defineModel('citation')
</script>

<style lang="scss" scoped>
.citation_form {
  margin-bottom: 1em;
}
</style>
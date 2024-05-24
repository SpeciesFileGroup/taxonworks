<template>
  <fieldset>
    <legend>Citation options</legend>
    <FormCitation
      v-model="citationOptions.citation"
      class="citation_form"
    />

    <div
      v-for="(label, param) in BOOL_PARAMETERS"
      :key="param"
      class="field"
    >
      <label>
        <input
          type="checkbox"
          v-model="citationOptions[param]"
        />
        {{ label }}
      </label>
    </div>

  </fieldset>
</template>

<script setup>
import FormCitation from '@/components/Form/FormCitation.vue'

const BOOL_PARAMETERS = {
  cite_matrix: 'Cite matrix with selected source',
  cite_otus: 'Cite new otus with selected source',
  cite_descriptors: 'Cite new descriptors with selected source',
  cite_observations: 'Cite new observations with selected source'
}

const citationOptions = defineModel()
citationOptions.value.citation = {}
</script>

<style lang="scss" scoped>
.citation_form {
  margin-bottom: 1em;
}
</style>
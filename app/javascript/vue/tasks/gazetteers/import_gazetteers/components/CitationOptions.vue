<template>
  <fieldset>
    <div class="field">
      <label>
        <input
          type="checkbox"
          v-model="citationOptions['cite_gzs']"
        />
        Cite imported gazetteers
      </label>
    </div>

    <legend>Citation options</legend>
    <FormCitation
      v-model="citationOptions.citation"
      class="citation_form"
    />
  </fieldset>
</template>

<script setup>
import FormCitation from '@/components/Form/FormCitation.vue'

const citationOptions = defineModel()
citationOptions.value.citation = {}
citationOptions.value.cite_gzs = false
</script>

<style lang="scss" scoped>
.citation_form {
  margin-bottom: 1em;
}
</style>
<template>
  <fieldset>
    <legend>Cite imported gazetteers</legend>
    <FormCitation
      v-model="citation"
      class="citation_form"
    />
  </fieldset>
</template>

<script setup>
import FormCitation from '@/components/Form/FormCitation.vue'

const citation = defineModel()
</script>

<style lang="scss" scoped>
.citation_form {
  margin-bottom: 1em;
}
</style>
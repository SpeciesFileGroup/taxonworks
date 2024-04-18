<template>
  Citations
  <div
    v-if="citations.length"
    v-for="citation in citations"
    :key="citation.id"
  >
    <div class="lead_citation">
      <a :href="citation.source.object_url" target="_blank">
        {{ citation.citation_source_body }}
      </a>
    </div>
  </div>
  <div v-else>
    <i>No citations</i>
  </div>
</template>

<script setup>
const props = defineProps({
  citations: {
    type: Array,
    default: []
  }
})
</script>

<style lang="scss" scoped>
.lead_citation {
  margin-bottom: 1em;
}
</style>
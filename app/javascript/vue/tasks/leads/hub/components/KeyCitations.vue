<template>
  <u>Citations</u>
  <div
    v-for="citation in citations"
    :key="citation.id"
  >
    <div class="lead_citation">
      <a :href="citation.source.object_url" target="_blank">
        {{ citation.citation_source_body }}
      </a>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  citations: {
    type: Array,
    required: true
  }
})
</script>

<style lang="scss" scoped>
.lead_citation {
  margin-bottom: 1em;
}
</style>
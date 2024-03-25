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
      <RadialAnnotator :global-id="citation.global_id" />
    </div>
  </div>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'

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
  display: flex;
  align-items: center;
  column-gap: .5em;
}
</style>
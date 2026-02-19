<template>
  <div class="text-base font-bold">Citations ({{ citations.length }})</div>
  <div
    v-if="citations.length"
    class="margin-medium-top margin-medium-bottom"
  >
    <ul class="taxonomic_history no_bullets">
      <template
        v-for="(item, index) in citations"
        :key="index"
      >
        <li
          v-if="item.label_html"
          class="history__record horizontal-left-content middle gap-small"
        >
          <RadialAnnotator :global-id="getGlobalId(item)" />
          <span v-html="item.label_html" />
        </li>
      </template>
    </ul>
  </div>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator'

const props = defineProps({
  citations: {
    type: Array,
    required: true
  }
})

function getGlobalId(citation) {
  return citation.data_attributes['history-object-id']
}
</script>
<style scoped>
.taxonomic_history li {
  margin-bottom: 10px;
}
</style>

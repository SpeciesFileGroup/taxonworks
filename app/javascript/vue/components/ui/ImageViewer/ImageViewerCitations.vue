<template>
  <div
    v-if="originalCitation"
    class="full_width panel content margin-small-left"
  >
    <h3>Original citation</h3>
    <span v-html="originalCitation" />
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  citations: {
    type: Array,
    required: true
  }
})

const originalCitation = computed(() =>
  props.citations
    .filter(citation => citation.is_original)
    .map(citation => [citation.source.object_label, citation.pages].filter(item => item).join(':'))
    .join('; ')
)

</script>

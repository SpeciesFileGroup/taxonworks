<template>
  <div class="text-base font-bold">Citations ({{ totalCount }})</div>
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
        <li
          v-if="hiddenCount && index === previewSize - 1"
          class="history__gap"
        >
          <VBtn
            color="primary"
            variant="tonal"
            @click="isExpanded = true"
          >
            Show {{ hiddenCount }} more
          </VBtn>
        </li>
      </template>
    </ul>
    <VBtn
      v-if="isCollapsible && isExpanded"
      color="primary"
      variant="tonal"
      @click="isExpanded = false"
    >
      Show less
    </VBtn>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import RadialAnnotator from '@/components/radials/annotator/annotator'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  citations: {
    type: Array,
    required: true
  },

  totalCount: {
    type: Number,
    required: true
  },

  previewSize: {
    type: Number,
    default: 10
  },

  isCollapsible: {
    type: Boolean,
    default: false
  }
})

const isExpanded = defineModel('expanded', {
  type: Boolean,
  default: false
})

const hiddenCount = computed(() => props.totalCount - props.citations.length)

function getGlobalId(citation) {
  return citation.data_attributes['history-object-id']
}
</script>
<style scoped>
.taxonomic_history li {
  margin-bottom: 10px;
}

/* The gap stands in for the citations that are not being shown */
.history__gap {
  padding: 0.5rem 0;
  border-top: 1px dashed var(--border-color);
  border-bottom: 1px dashed var(--border-color);
}
</style>

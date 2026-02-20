<template>
  <div v-if="enabled">
    <div
      v-if="!relatedObject"
      class="margin-small-top ap-related-hint"
    >
      Select a related object to add an anatomical part on.
    </div>

    <template v-else>
      <div
        v-if="relatedNeedsTaxonDetermination"
        class="margin-small-top"
      >
        The origin of an anatomical part requires a taxon determination on this {{ relatedObject.base_class }}.
      </div>

      <TaxonDeterminationOtu
        v-if="relatedNeedsTaxonDetermination"
        v-model="relatedTaxonDeterminationOtuId"
      />

      <CreateAnatomicalPart
        v-if="!relatedNeedsTaxonDetermination || relatedTaxonDeterminationOtuId"
        :key="`related-${relatedPartKey}`"
        class="margin-small-top margin-small-bottom"
        :include-is-material="relatedObject.base_class === 'FieldOccurrence'"
        @change="emit('change', $event)"
      />
    </template>
  </div>
</template>

<script setup>
import TaxonDeterminationOtu from '@/components/TaxonDetermination/TaxonDeterminationOtu.vue'
import CreateAnatomicalPart from './CreateAnatomicalPart.vue'

const relatedTaxonDeterminationOtuId = defineModel('relatedTaxonDeterminationOtuId', {
  type: Number,
  default: undefined
})

defineProps({
  enabled: {
    type: Boolean,
    default: false
  },

  relatedObject: {
    type: Object,
    default: undefined
  },

  relatedNeedsTaxonDetermination: {
    type: Boolean,
    default: false
  },

  relatedPartKey: {
    type: Number,
    required: true
  }
})

const emit = defineEmits(['change'])
</script>

<style scoped>
.ap-related-hint {
  color: var(--text-muted-color);
  font-size: 0.9rem;
}
</style>

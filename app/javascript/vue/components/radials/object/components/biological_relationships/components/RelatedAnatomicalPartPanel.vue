<template>
  <div v-if="enabled">
    <div
      v-if="biologicalRelation && relatedNeedsTaxonDetermination"
      class="margin-small-top"
    >
      The origin of an anatomical part requires a taxon determination on this {{ biologicalRelation.base_class }}.
    </div>

    <TaxonDeterminationOtu
      v-if="biologicalRelation && relatedNeedsTaxonDetermination"
      :model-value="relatedTaxonDeterminationOtuId"
      @update:model-value="
        emit('update:relatedTaxonDeterminationOtuId', $event)
      "
    />

    <CreateAnatomicalPart
      v-if="!relatedNeedsTaxonDetermination || relatedTaxonDeterminationOtuId || !biologicalRelation"
      :key="`related-${relatedPartKey}`"
      class="margin-small-top margin-small-bottom"
      :include-is-material="biologicalRelation?.base_class === 'FieldOccurrence'"
      :requires-is-material-before-template="biologicalRelation?.base_class === 'FieldOccurrence'"
      @change="emit('change', $event)"
    />
  </div>
</template>

<script setup>
import TaxonDeterminationOtu from '@/components/TaxonDetermination/TaxonDeterminationOtu.vue'
import CreateAnatomicalPart from './CreateAnatomicalPart.vue'

defineProps({
  enabled: {
    type: Boolean,
    default: false
  },

  biologicalRelation: {
    type: Object,
    default: undefined
  },

  relatedNeedsTaxonDetermination: {
    type: Boolean,
    default: false
  },

  relatedTaxonDeterminationOtuId: {
    type: Number,
    default: undefined
  },

  relatedPartKey: {
    type: Number,
    required: true
  }
})

const emit = defineEmits(['update:relatedTaxonDeterminationOtuId', 'change'])
</script>

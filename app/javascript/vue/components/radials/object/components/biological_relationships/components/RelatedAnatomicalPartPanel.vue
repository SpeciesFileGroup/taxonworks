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
      v-model="relatedTaxonDeterminationOtuId"
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

const relatedTaxonDeterminationOtuId = defineModel('relatedTaxonDeterminationOtuId', {
  type: Number,
  default: undefined
})

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

  relatedPartKey: {
    type: Number,
    required: true
  }
})

const emit = defineEmits(['change'])
</script>

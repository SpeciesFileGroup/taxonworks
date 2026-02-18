<template>
  <PanelLayout
    :status="status"
    :title="title"
  >
    <div
      v-if="taxonNameType"
      class="separate-top"
    >
      <p v-html="taxonNameType" />
    </div>
  </PanelLayout>
</template>

<script setup>
import { computed } from 'vue'
import PanelLayout from '../PanelLayout.vue'

const props = defineProps({
  otu: {
    type: Object,
    required: true
  },

  otus: {
    type: Array,
    required: true
  },

  taxonName: {
    type: Object,
    required: true
  },

  status: {
    type: String,
    default: 'unknown'
  },

  title: {
    type: String,
    default: 'Type'
  }
})

const taxonNameType = computed(
  () =>
    props.taxonName?.type_taxon_name_relationship?.object_tag ||
    'No type available'
)
</script>

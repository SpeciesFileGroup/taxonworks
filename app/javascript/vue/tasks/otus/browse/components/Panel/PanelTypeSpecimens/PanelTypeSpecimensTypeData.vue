<template>
  <div class="content">
    <span>
      <span v-html="`${type.type_type} of ${type.original_combination}`" /> |
      <a :href="urlType">Edit</a>
    </span>
    <ul>
      <li>
        <span>
          Citation: <b><span v-html="citationsLabel" /></b>
        </span>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { RouteNames } from '@/routes/routes'

const props = defineProps({
  type: {
    type: Object,
    required: true
  },

  otu: {
    type: Object,
    required: true
  }
})

const citationsLabel = computed(() =>
  props.type.citations.length
    ? props.type.citations
        .sort((a, b) => (b.is_original === true) - (a.is_original === true))
        .map((item) => item.citation_source_body)
        .join('; ')
    : 'not specified'
)

const urlType = computed(
  () =>
    `${RouteNames.TypeMaterial}?taxon_name_id=${props.otu.taxon_name_id}&type_material_id=${props.type.id}`
)
</script>

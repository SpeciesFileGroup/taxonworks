<template>
  <tr v-if="source">
    <td>
      <a
        v-html="source.cached"
        :href="`/sources/${source.id}`"
      />
    </td>
    <td class="horizontal-left-content gap-small">
      <RadialObject :global-id="source.global_id" />
      <VPin
        v-if="source.id"
        :object-id="source.id"
        :type="source.type"
      />
      <AddToProject
        :id="source.id"
        :in_project="source.source_in_project"
        :project-source-id="source.project_source_id"
      />
    </td>
  </tr>
</template>

<script setup>
import VPin from '@/components/ui/Button/ButtonPin.vue'
import AddToProject from '@/components/ui/Button/ButtonAddToProjectSource'
import RadialObject from '@/components/radials/navigation/radial'

defineProps({
  source: {
    type: Object,
    default: () => ({})
  }
})
</script>

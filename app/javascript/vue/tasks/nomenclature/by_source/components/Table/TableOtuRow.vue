<template>
  <tr>
    <td>
      <input
        type="checkbox"
        :value="otu.id"
        v-model="selected"
      />
    </td>
    <td>
      <a
        :href="`${RouteNames.BrowseOtu}?otu_id=${otu.id}`"
        v-html="otu.object_tag"
      />
    </td>
    <td>
      <div class="horizontal-right-content gap-small">
        <radial-annotator :global-id="otu.global_id" />
        <otu-radial
          :taxon-id="otu.global_id"
          :otu="otu"
          :redirect="false"
        />
        <otu-radial
          :taxon-id="otu.global_id"
          :otu="otu"
          redirect
        />
      </div>
    </td>
  </tr>
</template>

<script setup>
import { RouteNames } from '@/routes/routes'
import RadialAnnotator from '@/components/radials/annotator/annotator'
import OtuRadial from '@/components/otu/otu'

defineProps({
  otu: {
    type: Object,
    required: true
  }
})

const selected = defineModel({
  type: Array,
  default: () => []
})
</script>

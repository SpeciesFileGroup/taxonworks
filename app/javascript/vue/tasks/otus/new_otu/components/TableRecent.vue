<template>
  <table class="table-striped table-cells-border">
    <thead>
      <tr>
        <th>OTU</th>
        <th class="w-2" />
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="otu in list"
        :key="otu.id"
      >
        <td v-html="otu.object_tag" />
        <td>
          <div class="horizontal-left-content gap-small">
            <RadialAnnotator :global-id="otu.global_id" />
            <RadialObject :global-id="otu.global_id" />
            <RadialNavigator :global-id="otu.global_id" />
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'

defineProps({
  list: {
    type: Array,
    required: true
  }
})
</script>

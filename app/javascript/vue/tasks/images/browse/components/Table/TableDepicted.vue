<template>
  <table class="table-striped">
    <thead>
      <tr>
        <th>Depicted</th>
        <th></th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in records"
        :key="item.id"
      >
        <td v-html="item.object_tag" />
        <td>
          <div class="flex-row gap-small">
            <RadialAnnotator :global-id="item.global_id" />
            <RadialQuickForms :global-id="item.global_id" />
            <RadialNavigator :global-id="item.global_id" />
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import RadialQuickForms from '@/components/radials/object/radial.vue'

const props = defineProps({
  records: {
    type: Array,
    required: true
  }
})
</script>

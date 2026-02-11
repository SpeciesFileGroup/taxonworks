<template>
  <PanelLayout
    v-if="store.coordinateOtus.length"
    :status="status"
    :title="title"
  >
    <table class="full_width table-striped">
      <thead>
        <tr>
          <th>
            <ButtonUnify
              :ids="store.selectedOtus"
              :model="OTU"
            />
          </th>
          <th></th>
          <th>OTU</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="otu in store.coordinateOtus"
          :key="otu.id"
        >
          <td class="w-2">
            <input
              type="checkbox"
              :value="otu"
              v-model="store.selectedOtus"
            />
          </td>
          <td class="w-2">
            <div class="horizontal-left-content gap-small">
              <RadialAnnotator :global-id="otu.global_id" />
              <RadialObject :global-id="otu.global_id" />
              <RadialNavigator :global-id="otu.global_id" />
            </div>
          </td>
          <td v-html="otu.object_tag" />
        </tr>
      </tbody>
    </table>
  </PanelLayout>
</template>

<script setup>
import { OTU } from '@/constants'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import PanelLayout from '../PanelLayout.vue'
import ButtonUnify from '@/components/ui/Button/ButtonUnify.vue'
import { useOtuStore } from '../../../store'

defineProps({
  otu: {
    type: Object,
    required: true
  }
})

const store = useOtuStore()
</script>

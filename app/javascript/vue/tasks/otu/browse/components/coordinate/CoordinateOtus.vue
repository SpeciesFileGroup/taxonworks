<template>
  <section-panel
    v-if="otus.filter((item) => item.id !== currentOtu?.id).length"
    :status="status"
    :title="title"
  >
    <table class="full_width table-striped">
      <thead>
        <tr>
          <th>
            <ButtonUnify
              :ids="selected"
              :model="OTU"
            />
          </th>
          <th></th>
          <th>OTU</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="otu in otus"
          :key="otu.id"
        >
          <td class="w-2">
            <input
              type="checkbox"
              :value="otu.id"
              v-model="selected"
            />
          </td>
          <td class="w-2">
            <div class="horizontal-left-content gap-xsmall">
              <RadialAnnotator :global-id="otu.global_id" />
              <RadialObject :global-id="otu.global_id" />
              <RadialNavigator :global-id="otu.global_id" />
            </div>
          </td>
          <td v-html="otu.object_tag" />
        </tr>
      </tbody>
    </table>
  </section-panel>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import { OTU } from '@/constants'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import SectionPanel from '../shared/sectionPanel'
import ButtonUnify from '@/components/ui/Button/ButtonUnify.vue'

defineProps({
  status: {
    type: String,
    default: undefined
  },

  title: {
    type: String,
    required: true
  }
})

const store = useStore()
const otus = computed(() => store.getters[GetterNames.GetOtus])
const currentOtu = computed(() => store.getters[GetterNames.GetCurrentOtu])
const selected = ref([])
</script>

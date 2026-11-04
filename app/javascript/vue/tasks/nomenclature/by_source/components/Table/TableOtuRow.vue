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
      <VBtn
        color="primary"
        :disabled="!depictions.length"
        @click="isDepictionsModalVisible = true"
      >
        Show ({{ depictions.length }})
      </VBtn>
      <DepictionsModal
        v-if="isDepictionsModalVisible"
        :otus="[otu]"
        :depictions-by-otu="{ [otu.id]: depictions }"
        @close="isDepictionsModalVisible = false"
      />
    </td>
    <td>
      <div class="horizontal-right-content gap-small">
        <otu-radial
          :taxon-id="otu.global_id"
          :otu="otu"
          redirect
        />
        <radial-annotator :global-id="otu.global_id" />
        <otu-radial
          :taxon-id="otu.global_id"
          :otu="otu"
          :redirect="false"
        />
      </div>
    </td>
  </tr>
</template>

<script setup>
import { ref } from 'vue'
import { RouteNames } from '@/routes/routes'
import RadialAnnotator from '@/components/radials/annotator/annotator'
import OtuRadial from '@/components/otu/otu'
import VBtn from '@/components/ui/VBtn/index.vue'
import DepictionsModal from '../DepictionsModal.vue'

defineProps({
  otu: {
    type: Object,
    required: true
  },

  depictions: {
    type: Array,
    default: () => []
  }
})

const selected = defineModel({
  type: Array,
  default: () => []
})

const isDepictionsModalVisible = ref(false)
</script>

<template>
  <SectionPanel
    :spinner="isLoading"
    :status="status"
    :title="title"
  >
    <AnimationOpacity>
      <DescendantsTree
        v-if="taxonomy"
        :taxonomy="taxonomy"
      />
    </AnimationOpacity>
  </SectionPanel>
</template>

<script setup>
import SectionPanel from '../shared/sectionPanel'
import DescendantsTree from './DescendantsTree.vue'
import { ref, watch } from 'vue'
import { Otu } from '@/routes/endpoints'

const props = defineProps({
  status: {
    type: String,
    default: 'unknown'
  },
  title: {
    type: String,
    default: undefined
  },
  otu: {
    type: Object,
    required: true
  }
})

const taxonomy = ref(null)
const isLoading = ref(false)

watch(
  () => props.otu?.id,
  async (otuId) => {
    if (!otuId) {
      return
    }

    isLoading.value = true
    Otu.taxonomy(otuId, {
      max_descendants_depth: 1
    })
      .then(({ body }) => {
        taxonomy.value = body
      })
      .finally(() => (isLoading.value = false))
  },
  { immediate: true }
)
</script>

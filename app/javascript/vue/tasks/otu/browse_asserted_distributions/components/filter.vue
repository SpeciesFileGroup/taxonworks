<template>
  <BlockLayout>
    <template #header>
      <h3>OTU</h3>
    </template>

    <template #options>
      <VBtn
        color="primary"
        circle
        @click="resetFilter"
      >
        <VIcon
          name="reset"
          x-small
          title="Reset"
        />
      </VBtn>
    </template>

    <template #body>
      <OtuComponent v-model="otuId" />
      <OtuLinks :otu-id="otuId" />
    </template>
  </BlockLayout>
</template>

<script setup>
import { ref, watch } from 'vue'
import { setParam } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import OtuComponent from './filters/otu'
import OtuLinks from './navBar'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'

const otuId = ref(null)

const emit = defineEmits(['select'])

watch(otuId, (newVal) => {
  if (newVal) {
    emit('select', { otu_id: newVal })
  }

  setParam(RouteNames.BrowseAssertedDistribution, 'otu_id', newVal)
})

function resetFilter() {
  emit('reset')
  otuId.value = null
}
</script>
<style scoped>
:deep(.btn-delete) {
  background-color: var(--color-primary);
}
</style>

<template>
  <BlockLayout
    class="previous"
    expand
  >
    <template #header>
      <h3>Previous couplets</h3>
    </template>

    <template #body>
      <PreviousCoupletsList
        :past="[...parents, lead]"
        :load-function="(id) => emit('loadCouplet', id)"
        :route-name="RouteNames.ShowLead"
        :root-text="rootText"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import PreviousCoupletsList from '../../components/PreviousCoupletsList.vue'
import { RouteNames } from '@/routes/routes'

const props = defineProps({
  parents: {
    type: Array,
    required: true
  },
  rootText: {
    type: String,
    required: true
  },
  lead: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['loadCouplet'])
</script>

<style lang="scss" scoped>
.previous {
  max-width: 600px;
  margin: 2em auto;
}
</style>
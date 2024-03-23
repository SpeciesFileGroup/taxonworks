<template>
  <BlockLayout
    class="new-lead-previous"
    expand
  >
    <template #header>
      <h3>Previous couplets</h3>
    </template>

    <template #body>
      <PreviousCoupletsList
        :past="[...store.parents, store.lead]"
        :load-function="store.loadKey"
        :route-name="RouteNames.NewLead"
        :root-text="store.root.text"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { RouteNames } from '@/routes/routes'
import { useStore } from '../store/useStore.js'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import PreviousCoupletsList from '../../components/PreviousCoupletsList.vue'

const store = useStore()
</script>

<style lang="scss" scoped>
.new-lead-previous {
  max-width: 600px;
  margin: 2em auto;
}
</style>

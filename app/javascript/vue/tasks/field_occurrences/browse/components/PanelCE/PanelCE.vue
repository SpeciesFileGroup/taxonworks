<template>
  <BlockLayout v-if="store.collectingEvent">
    <template #header>
      <div class="flex-separate middle full_width">
        <h3>Collecting event</h3>
        <div class="horizontal-right-content gap-small">
          <RadialAnnotator :global-id="store.collectingEvent.global_id" />
          <RadialNavigator :global-id="store.collectingEvent.global_id" />
        </div>
      </div>
    </template>
    <template #body>
      <TableGrid :columns="1">
        <PanelCEAttributes />
      </TableGrid>
    </template>
  </BlockLayout>
</template>

<script setup>
import useCollectingEventStore from '../../store/collectingEvent.js'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import PanelCEAttributes from './PanelCEAttributes.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import TableGrid from '@/components/layout/Table/TableGrid.vue'

const store = useCollectingEventStore()
</script>

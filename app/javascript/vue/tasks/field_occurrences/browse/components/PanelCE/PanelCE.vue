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
        <PanelCEAttributes @row-click="setRow" />
      </TableGrid>
      <PanelCEModal
        v-if="row"
        :param="row"
        :textarea="TEXTAREA_FIELDS.includes(row.field)"
        :collecting-event-id="store.collectingEvent.id"
        @close="() => (row = undefined)"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import useCollectingEventStore from '../../store/collectingEvent.js'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import PanelCEAttributes from './PanelCEAttributes.vue'
import PanelCEModal from './PanelCEModal.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import TableGrid from '@/components/layout/Table/TableGrid.vue'
import { ref } from 'vue'

const TEXTAREA_FIELDS = [
  'document_label',
  'print_label',
  'verbatim_label',
  'verbatim_locality'
]

const NO_EDITABLE_FIELDS = [
  'created_at',
  'updated_at',
  'global_id',
  'id',
  'cached_level0_geographic_name',
  'cached_level1_geographic_name',
  'cached_level2_geographic_name'
]

const store = useCollectingEventStore()
const row = ref()

function setRow(rowObject) {
  if (!NO_EDITABLE_FIELDS.includes(rowObject.field)) {
    row.value = rowObject
  }
}
</script>

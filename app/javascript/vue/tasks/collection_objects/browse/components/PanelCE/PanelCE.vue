<template>
  <BlockLayout v-if="collectingEvent.id">
    <template #header>
      <div class="flex-separate middle full_width">
        <h3>Collecting event</h3>
        <RadialFilterAttribute
          :parameters="{ collecting_event_id: [collectingEvent.id] }"
        />
        <div class="horizontal-right-content gap-small">
          <RadialAnnotator :global-id="collectingEvent.global_id" />
          <RadialNavigator :global-id="collectingEvent.global_id" />
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
        :textarea="textareaFields.includes(row.field)"
        :collecting-event-id="collectingEvent.id"
        @close="row = undefined"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed, ref } from 'vue'
import { GetterNames } from '../../store/getters/getters'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import PanelCEAttributes from './PanelCEAttributes.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import TableGrid from '@/components/layout/Table/TableGrid.vue'
import RadialFilterAttribute from '@/components/radials/linker/RadialFilterAttribute.vue'
import PanelCEModal from './PanelCEModal.vue'

const notEditableFields = [
  'created_at',
  'updated_at',
  'global_id',
  'id',
  'cached_level0_geographic_name',
  'cached_level1_geographic_name',
  'cached_level2_geographic_name'
]

const textareaFields = [
  'document_label',
  'print_label',
  'verbatim_label',
  'verbatim_locality'
]

function setRow(rowObject) {
  if (!notEditableFields.includes(rowObject.field)) {
    row.value = rowObject
  }
}

const row = ref(undefined)

const store = useStore()
const collectingEvent = computed(
  () => store.getters[GetterNames.GetCollectingEvent]
)
</script>

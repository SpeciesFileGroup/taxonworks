<template>
  <BlockLayout v-if="collectingEvent.id">
    <template #header>
      <div class="flex-separate middle full_width">
        <h3>Collecting event</h3>
        <div class="horizontal-right-content">
          <RadialAnnotator :global-id="collectingEvent.global_id" />
          <RadialObject :global-id="collectingEvent.global_id" />
          <RadialNavigator :global-id="collectingEvent.global_id" />
        </div>
      </div>
    </template>
    <template #body>
      <TableGrid
        :columns="1"
      >
        <TableGrid
          :columns="2"
          gap="1em"
          :column-width="{
            default: 'min-content',
            0: '.5fr',
            1: '1fr'
          }"
        >
          <PanelCEAttributes />
          <TableGrid
            :columns="1"
            gap="1em"
            :column-width="{
              default: 'min-content',
              0: '1fr'
            }"
          >
            <PanelMap height="100%" />
            <PanelIdentifier :type="COLLECTING_EVENT" />
            <SoftValidations
              class="column-validation"
              :validations="store.getters[GetterNames.GetSoftValidationFor](COLLECTING_EVENT)"
            />
          </TableGrid>
        </TableGrid>
      </TableGrid>
    </template>
  </BlockLayout>
</template>

<script setup>
import { COLLECTING_EVENT } from 'constants/index.js'
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters'
import PanelMap from '../Panel/PanelMap.vue'
import BlockLayout from 'components/layout/BlockLayout.vue'
import PanelCEAttributes from './PanelCEAttributes.vue'
import PanelIdentifier from '../Panel/PanelIdentifier.vue'
import SoftValidations from 'components/soft_validations/panel.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import RadialObject from 'components/radials/object/radial.vue'
import RadialNavigator from 'components/radials/navigation/radial.vue'
import TableGrid from 'components/layout/Table/TableGrid.vue'

const store = useStore()
const collectingEvent = computed(() => store.getters[GetterNames.GetCollectingEvent])

</script>

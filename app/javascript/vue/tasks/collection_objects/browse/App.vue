<template>
  <div id="vue-browse-collection-object">
    <h1>Browse collection object</h1>
    <COHeader />
    <TableGrid
      :columns="collectingEvent.id ? 1 : 2"
      gap="1em"
    >
      <TableGrid
        class="margin-medium-bottom"
        :columns="collectingEvent.id ? 2 : 1"
        gap="1em"
        :column-width="{
          default: 'min-content',
          0: '1fr',
          1: '2fr',
        }"
      >
        <PanelCO />
        <PanelCE />
      </TableGrid>

      <TableGrid
        :columns="3"
        :column-width="{
          default: 'min-content',
          0: '1fr',
          1: '1fr',
          2: '2fr'
        }"
        gap="1em"
      >
        <PanelDwc />
        <PanelDepictions />
        <PanelTimeline />
      </TableGrid>
    </TableGrid>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { URLParamsToJSON } from 'helpers/url/parse'
import { ActionNames } from './store/actions/actions'
import PanelDwc from './components/Panel/PanelDwc.vue'
import PanelTimeline from './components/Panel/PanelTimeline.vue'
import COHeader from './components/COHeader.vue'
import TableGrid from 'components/layout/Table/TableGrid.vue'
import PanelDepictions from './components/Panel/PanelDepictions.vue'
import PanelCE from './components/PanelCE/PanelCE.vue'
import PanelCO from './components/Panel/PanelCO.vue'
import { GetterNames } from './store/getters/getters'

const store = useStore()
const collectingEvent = computed(() => store.getters[GetterNames.GetCollectingEvent])
const { collection_object_id: coId } = URLParamsToJSON(location.href)

if (coId) {
  store.dispatch(ActionNames.LoadCollectionObject, coId)
}
</script>

<style lang="scss">
#vue-browse-collection-object {

  .panel {
    border-radius: 0px;
    box-shadow: 0 3 6 0 rgba(0,0,0, .18);

    &__title {
      padding: 0px;
      margin: 0px;
      font-size: 1em;
      text-transform: uppercase;
      color: #444444;
    }

    &__subtitle {
      font-size: 1em;
      font-weight: 700;
    }

    &__content {
      padding: 2em;
    }
  }
}
</style>

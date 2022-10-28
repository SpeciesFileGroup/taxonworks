<template>
  <div id="vue-browse-collection-object">
    <h1>Browse collection object</h1>
    <COHeader />
    <TableGrid
      :columns="1"
      gap="1em"
    >
      <TableGrid
        :columns="collectingEvent.id ? 3 : 2"
        gap="1em"
        :column-width="{
          default: 'min-content',
          0: '1fr',
          1: '2fr',
          2: '1fr'
        }"
      >
        <PanelCO />
        <PanelCE />
        <ColumnThree />
      </TableGrid>

      <PanelDerived />
    </TableGrid>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { URLParamsToJSON } from 'helpers/url/parse'
import { ActionNames } from './store/actions/actions'
import COHeader from './components/COHeader.vue'
import TableGrid from 'components/layout/Table/TableGrid.vue'
import PanelCE from './components/PanelCE/PanelCE.vue'
import PanelCO from './components/Panel/PanelCO.vue'
import ColumnThree from './components/ColumnThree.vue'
import PanelDerived from './components/Panel/PanelDerived.vue'
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
    //box-shadow: 0 3 6 0 rgba(0,0,0, .18);

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

<template>
  <div id="vue-browse-collection-object">
    <div class="flex flex-separate middle">
      <h1>Browse collection object</h1>
      <VAutocomplete
        class="autocomplete"
        url="/collection_objects/autocomplete"
        placeholder="Search a collection object"
        param="term"
        label="label_html"
        clear-after
        @get-item="loadCO($event.id)"
      />
    </div>
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
          1: collectingEvent.id ? '2fr' : '1fr',
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
import { GetterNames } from './store/getters/getters'
import VAutocomplete from 'components/ui/Autocomplete.vue'
import COHeader from './components/COHeader.vue'
import TableGrid from 'components/layout/Table/TableGrid.vue'
import PanelCE from './components/PanelCE/PanelCE.vue'
import PanelCO from './components/Panel/PanelCO.vue'
import ColumnThree from './components/ColumnThree.vue'
import PanelDerived from './components/Panel/PanelDerived.vue'
import loadCO from './utils/loadCO.js'

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

  .autocomplete {
    width: 600px;
  }
}
</style>

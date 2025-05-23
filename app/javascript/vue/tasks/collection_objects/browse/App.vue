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
        autofocus
        clear-after
        @get-item="({ id }) => loadCO(id)"
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
import { URLParamsToJSON } from '@/helpers/url/parse'
import { ActionNames } from './store/actions/actions'
import { GetterNames } from './store/getters/getters'
import { RouteNames } from '@/routes/routes'
import { usePopstateListener } from '@/composables'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import COHeader from './components/COHeader.vue'
import TableGrid from '@/components/layout/Table/TableGrid.vue'
import PanelCE from './components/PanelCE/PanelCE.vue'
import PanelCO from './components/Panel/PanelCO.vue'
import ColumnThree from './components/ColumnThree.vue'
import PanelDerived from './components/Panel/PanelDerived.vue'
import setParam from '@/helpers/setParam'

const store = useStore()
const collectingEvent = computed(
  () => store.getters[GetterNames.GetCollectingEvent]
)
const { collection_object_id: coId } = URLParamsToJSON(location.href)

if (coId) {
  // Call this for history.replaceState - otherwise turbolinks saves state
  // that causes a reload every time we revisit this initial CO.
  setParam(RouteNames.BrowseCollectionObject, 'collection_object_id', coId)
  store.dispatch(ActionNames.LoadCollectionObject, coId)
}

function loadCO(coId, doSetParam = true) {
  store.dispatch(ActionNames.ResetStore)
  store.dispatch(ActionNames.LoadCollectionObject, coId)
  if (doSetParam) {
    setParam(RouteNames.BrowseCollectionObject, 'collection_object_id', coId)
  }
}

usePopstateListener(() => {
  const { collection_object_id: coId } = URLParamsToJSON(location.href)

  if (coId) {
    loadCO(coId, false)
  }
})
</script>

<style lang="scss">
#vue-browse-collection-object {
  .panel {
    &__title {
      padding: 0px;
      margin: 0px;
      text-transform: uppercase;
      color: #444444;
    }

    &__subtitle {
      font-size: 1em;
      font-weight: 700;
    }
  }

  .autocomplete {
    width: 600px;
  }
}
</style>

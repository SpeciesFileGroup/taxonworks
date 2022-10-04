<template>
  <div id="vue-browse-collection-object">
    <h1>Browse collection object</h1>
    <COHeader />
    <div class="horizontal-left-content align-start margin-medium-bottom">
      <div class="flex-column">
        <PanelBuffered class="margin-medium-bottom" />
        <PanelMap />
      </div>
      <div class="margin-medium-left">
        <PanelIdentifier />
      </div>
    </div>
    <div>
      <PanelDwc />
      <PanelCEAttributes />
    </div>
  </div>
</template>

<script setup>
import { useStore } from 'vuex'
import { URLParamsToJSON } from 'helpers/url/parse'
import { ActionNames } from './store/actions/actions'
import PanelBuffered from './components/Panel/PanelBuffered/PanelBuffered.vue'
import PanelIdentifier from './components/Panel/PanelIdentifier.vue'
import PanelDwc from './components/Panel/PanelDwc.vue'
import PanelCEAttributes from './components/PanelCE/PanelCEAttributes.vue'
import PanelMap from './components/Panel/PanelMap.vue'
import COHeader from './components/COHeader.vue'

const store = useStore()
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

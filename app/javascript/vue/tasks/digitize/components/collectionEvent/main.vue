<template>
  <div>
    <block-layout>
      <div slot="header">
        <h3>Collection Event</h3>
      </div>
      <div slot="options">
        <radial-annotator 
          v-if="collectingEvent.id"
          :global-id="collectingEvent.global_id"/>
      </div>
      <div slot="body">
        <smart-selector
          name="collection-event"
          v-model="view"
          :options="tabs"/>
        <div class="horizontal-left-content align-start">
          <block-verbatin class="separate-right"/>
          <block-geography class="separate-left separate-right"/>
          <block-map class="separate-left"/>
        </div>
      </div>
    </block-layout>
  </div>
</template>

<script>

  import BlockVerbatin from './components/verbatimLayout.vue'
  import BlockGeography from './components/GeographyLayout.vue'
  import SmartSelector from '../../../../components/switch.vue'
  import BlockMap from  './components/map/main.vue'
  import BlockLayout from '../../../../components/blockLayout.vue'
  import RadialAnnotator from '../../../../components/annotator/annotator.vue'
  import { GetterNames } from '../../store/getters/getters.js'

  export default {
    components: {
      BlockLayout,
      BlockVerbatin,
      BlockGeography,
      SmartSelector,
      RadialAnnotator,
      BlockMap
    },
    computed: {
      collectingEvent() {
        return this.$store.getters[GetterNames.GetCollectionEvent]
      }
    },
    data() {
      return {
        view: 'new',
        tabs: ['Quick', 'Recent', 'Pinboard', 'Search', 'New'],
      }
    }
  }
</script>
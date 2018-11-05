<template>
  <div>
    <block-layout>
      <div slot="header">
        <h3>Collection Event</h3>
      </div>
      <div
        slot="options" 
        class="horizontal-left-content separate-right">
        <radial-annotator 
          v-if="collectingEvent.id"
          :global-id="collectingEvent.global_id"/>
        <pin-component 
          v-if="collectingEvent.id"
          :object-id="collectingEvent.id" 
          type="CollectingEvent"/>
      </div>
      <div slot="body">
        <smart-selector
          name="collection-event"
          v-model="view"
          :add-option="staticOptions"
          :options="tabs"/>
        <component
          :is="actualComponent"
          :list="lists[view]"/>
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
  import SmartSelector from 'components/switch.vue'
  import BlockMap from  './components/map/main.vue'
  import BlockLayout from 'components/blockLayout.vue'
  import RadialAnnotator from 'components/annotator/annotator.vue'
  import { GetterNames } from '../../store/getters/getters.js'
  import PinComponent from 'components/pin.vue'
  import { GetCollectingEventsSmartSelector } from '../../request/resources.js'

  import SearchComponent from './components/smart/search.vue'

  import { 
    default as QuickComponent, 
    default as RecentComponent, 
    default as PinboardComponent
  } from './components/smart/smartList.vue'

  export default {
    components: {
      BlockLayout,
      BlockVerbatin,
      BlockGeography,
      SmartSelector,
      RadialAnnotator,
      PinComponent,
      BlockMap,
      SearchComponent,
      RecentComponent,
      PinboardComponent,
      QuickComponent
    },
    computed: {
      collectingEvent() {
        return this.$store.getters[GetterNames.GetCollectionEvent]
      },
      actualComponent() {
        return (this.view + 'Component')
      }
    },
    data() {
      return {
        view: 'search',
        tabs: [],
        staticOptions: ['search'],
        lists: []
      }
    },
    mounted() {
      GetCollectingEventsSmartSelector().then(response => {
        this.tabs = Object.keys(response)
        this.lists = response
      })
    }
  }
</script>
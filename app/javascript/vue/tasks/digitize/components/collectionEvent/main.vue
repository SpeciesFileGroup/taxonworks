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
        <fieldset class="separate-bottom">
          <legend>Selector</legend>
          <div class="horizontal-left-content separate-bottom">
            <smart-selector
              name="collection-event"
              v-model="view"
              :add-option="staticOptions"
              :options="tabs"/>
            <pin-default
              class="separate-left"
              section="CollectingEvents"
              @getId="getCollectingEvent"
              type="CollectingEvent"/>
          </div>
          <component
            :is="actualComponent"
            :list="lists[view]"/>
        </fieldset>
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
  import { MutationNames } from '../../store/mutations/mutations.js'
  import PinComponent from 'components/pin.vue'
  import PinDefault from 'components/getDefaultPin'
  import { GetCollectingEventsSmartSelector, GetCollectionEvent } from '../../request/resources.js'
  import makeCollectingEvent from '../../const/collectingEvent.js'

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
      QuickComponent,
      PinDefault
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
    },
    methods: {
      getCollectingEvent(id) {
        GetCollectionEvent(id).then(response => {
          this.$store.commit(MutationNames.SetCollectionEvent, Object.assign(makeCollectingEvent(), response))
        })
      }
    }
  }
</script>
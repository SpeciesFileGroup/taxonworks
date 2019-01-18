<template>
  <div>
    <block-layout :warning="!collectingEvent.id">
      <div slot="header">
        <h3>Collection Event</h3>
      </div>
      <div
        slot="options" 
        class="horizontal-left-content separate-right">
        <span v-if="collectingEvent.id">Sequential uses: {{ (this.subsequentialUses == 0 ? '-' : this.subsequentialUses) }}</span>
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
              class="separate-right"
              v-model="view"
              :add-option="staticOptions"
              :options="tabs"/>
            <lock-component 
              v-model="locked.collecting_event"/>
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
          <block-verbatin class="separate-right item"/>
          <block-geography class="separate-left item separate-right"/>
          <block-map class="separate-left item"/>
        </div>
      </div>
    </block-layout>
  </div>
</template>

<script>

  import BlockVerbatin from './components/verbatimLayout.vue'
  import BlockGeography from './components/GeographyLayout.vue'
  import SmartSelector from 'components/switch.vue'
  import LockComponent from 'components/lock.vue'
  import BlockMap from  './components/map/main.vue'
  import BlockLayout from 'components/blockLayout.vue'
  import RadialAnnotator from 'components/annotator/annotator.vue'
  import { GetterNames } from '../../store/getters/getters.js'
  import { MutationNames } from '../../store/mutations/mutations.js'
  import PinComponent from 'components/pin.vue'
  import PinDefault from 'components/getDefaultPin'
  import { GetCollectingEventsSmartSelector, GetCollectionEvent } from '../../request/resources.js'
  import makeCollectingEvent from '../../const/collectingEvent.js'
  import orderSmartSelector from '../../helpers/orderSmartSelector.js'

  import SearchComponent from './components/smart/search.vue'
  import selectFirstSmartOption from '../../helpers/selectFirstSmartOption'

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
      PinDefault,
      LockComponent
    },
    computed: {
      collectingEvent() {
        return this.$store.getters[GetterNames.GetCollectionEvent]
      },
      actualComponent() {
        return (this.view + 'Component')
      },
      subsequentialUses: {
        get() {
          return this.$store.getters[GetterNames.GetSubsequentialUses]
        },
        set(value) {
          this.$store.commit(MutationNames.SetSubsequentialUses, value)
        }
      },
      locked: {
        get() {
          return this.$store.getters[GetterNames.GetLocked]
        },
        set(value) {
          this.$store.commit([MutationNames.SetLocked, value])
        }
      },
    },
    data() {
      return {
        view: 'search',
        tabs: [],
        staticOptions: ['search'],
        lists: []
      }
    },
    watch: {
      collectingEvent(newVal, oldVal) {
        if(!(newVal.hasOwnProperty('id') && 
        oldVal.hasOwnProperty('id') &&
        newVal.id == oldVal.id)) {
          this.subsequentialUses = 0
        }
      }
    },
    mounted() {
      GetCollectingEventsSmartSelector().then(response => {
        this.tabs = orderSmartSelector(Object.keys(response))
        this.lists = response
        this.view = selectFirstSmartOption(response, this.tabs)
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
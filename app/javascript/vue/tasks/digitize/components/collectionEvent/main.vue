<template>
  <div>
    <h2>Collection Event</h2>
    <smart-selector
      name="collection-event"
      v-model="view"
      :options="tabs"/>
    <div class="horizontal-left-content align-start">
      <block-verbatin class="separate-right"/>
      <block-geography class="separate-left"/>
      <block-map/>
    </div>
  </div>
</template>

<script>

  import BlockVerbatin from './components/verbatimLayout.vue'
  import BlockGeography from './components/GeographyLayout.vue'
  import SmartSelector from '../../../../components/switch.vue'
  import BlockMap from  './components/map/main.vue'

  export default {
    components: {
      BlockVerbatin,
      BlockGeography,
      SmartSelector,
      BlockMap
    },
    data() {
      return {
        view: 'new',
        tabs: ['Quick', 'Recent', 'Pinboard', 'Search', 'New'],
        blocks: {
          
        }
      }
    }
  }
</script>
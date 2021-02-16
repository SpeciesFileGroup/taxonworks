<template>
  <div class="panel content">
    <h2>Origin</h2>
    <switch-component
      class="margin-small-bottom"
      v-model="tabSelected"
      :options="tabsOptions"/>
    <smart-selector
      :model="smartConfig.model"/>
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import SwitchComponent from 'components/switch'

const smartTypes = [{
  label: 'Collection Object',
  model: 'collection_objects'
},
{
  label: 'Extract',
  model: 'extracts'
}]

export default {
  components: {
    SmartSelector,
    SwitchComponent
  },
  data () {
    return {
      smartTypes: smartTypes,
      tabSelected: smartTypes[0].label
    }
  },
  computed: {
    smartConfig () {
      return this.smartTypes.find(type => type.label === this.tabSelected)
    },
    tabsOptions () {
      return this.smartTypes.map(({ label }) => label)
    }
  }
}
</script>

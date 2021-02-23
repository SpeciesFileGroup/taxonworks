<template>
  <div class="panel content">
    <h2>Origin</h2>
    <switch-component
      class="margin-small-bottom"
      v-model="tabSelected"
      :options="tabsOptions"/>
    <lock-component v-model="settings.lock.origin"/>
    <smart-selector
      :model="smartConfig.model"/>
    <label>
      <input
        type="checkbox">
      Substract from origin
    </label>
    <label>
      Verbatim anatomical origin
      <input
        type="text"
        v-model="extract.verbatim_anatomical_origin">
    </label>
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import SwitchComponent from 'components/switch'
import LockComponent from 'components/lock'
import props from './mixins/props'

const smartTypes = [{
  label: 'Collection Object',
  model: 'collection_objects'
},
{
  label: 'Extract',
  model: 'extracts'
}]

export default {
  mixins: [props],
  components: {
    LockComponent,
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

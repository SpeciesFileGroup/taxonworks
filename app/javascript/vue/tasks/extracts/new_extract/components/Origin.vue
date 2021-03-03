<template>
  <div>
    <h2>Origin</h2>
    <div class="horizontal-left-content middle margin-small-bottom">
      <switch-component
        v-model="tabSelected"
        :options="tabsOptions"/>
      <lock-component
        class="margin-small-left"
        v-model="settings.lock.origin"/>
    </div>

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
import componentExtend from './mixins/componentExtend'

const smartTypes = [{
  label: 'CollectionObject',
  model: 'collection_objects'
},
{
  label: 'Extract',
  model: 'extracts'
}]

const newOrigin = () => ({
  old_object_id: undefined,
  old_object_type: undefined
})

export default {
  mixins: [componentExtend],
  components: {
    LockComponent,
    SmartSelector,
    SwitchComponent
  },

  data () {
    return {
      smartTypes: smartTypes,
      tabSelected: smartTypes[0].label,
      origin: newOrigin()
    }
  },

  computed: {
    smartConfig () {
      return this.smartTypes.find(type => type.label === this.tabSelected)
    },
    tabsOptions () {
      return this.smartTypes.map(({ label }) => label)
    }
  },

  methods: {
    addOrigin (origin) {
      this.extract.origin_relationships_attributes.push({
        old_object_id: origin.id,
        old_object_type: this.tabSelected.label
      })
    }
  }
}
</script>

<template>
  <div>
    <h2>Origin</h2>
    <template v-if="!selectedOrigin">
      <div class="horizontal-left-content middle margin-small-bottom">
        <switch-component
          v-model="tabSelected"
          :options="tabsOptions"/>
        <lock-component
          class="margin-small-left"
          v-model="settings.lock.origin"/>
      </div>

      <smart-selector
        :model="smartConfig.model"
        @selected="setOrigin"/>
    </template>

    <div
      v-if="selectedOrigin"
      class="horizontal-left-content">
      <span v-html="selectedOrigin.object_tag"/>
      <button
        class="button circle-button btn-undo button-default"
        type="button"
        @click="selectedOrigin = undefined"/>
    </div>
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
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

const smartTypes = [{
  label: 'CollectionObject',
  model: 'collection_objects'
},
{
  label: 'Extract',
  model: 'extracts'
}]

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
      selectedOrigin: undefined
    }
  },

  computed: {
    smartConfig () {
      return this.smartTypes.find(type => type.label === this.tabSelected)
    },

    tabsOptions () {
      return this.smartTypes.map(({ label }) => label)
    },

    originRelationship: {
      get () {
        return this.$store.getters[GetterNames.GetOriginRelationship]
      },
      set (value) {
        this.$store.commit(MutationNames.SetOriginRelationship, value)
      }
    }
  },

  watch: {
    selectedOrigin (newVal) {
      this.originRelationship.old_object_id = newVal.id
      this.originRelationship.old_object_type = newVal.base_class || 'CollectionObject'
    }
  },

  methods: {
    setOrigin (origin) {
      this.selectedOrigin = origin
    }
  }
}
</script>

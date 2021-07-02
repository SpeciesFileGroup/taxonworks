<template>
  <fieldset class="full_width">
    <legend>Related</legend>
    <switch-component
      class="separate-bottom"
      :options="tabOptions"
      v-model="view"
      name="related"
    />
    <smart-selector
      v-show="otuView"
      class="full_width"
      ref="otuSmartSelector"
      model="otus"
      target="BiologicalAssociation"
      klass="BiologicalAssociation"
      pin-section="Otus"
      pin-type="Otu"
      :autocomplete="false"
      :otu-picker="true"
      @selected="sendRelated"
    />
    <smart-selector
      v-show="!otuView"
      ref="smartSelector"
      class="full_width"
      model="collection_objects"
      target="BiologicalAssociation"
      klass="BiologicalAssociation"
      pin-section="CollectionObjects"
      pin-type="CollectionObject"
      @selected="sendRelated"
    />
  </fieldset>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import SwitchComponent from 'components/switch.vue'

import { GetterNames } from '../../store/getters/getters'

export default {
  components: {
    SwitchComponent,
    SmartSelector
  },

  emits: ['select'],

  computed: {
    otuView () {
      return this.view === 'otu'
    },
    lastSave () {
      return this.$store.getters[GetterNames.GetLastSave]
    }
  },

  data () {
    return {
      view: 'otu',
      tabOptions: ['otu', 'collection object']
    }
  },

  watch: {
    lastSave (newVal) {
      this.$refs.smartSelector.refresh()
      this.$refs.otuSmartSelector.refresh()
    }
  },

  methods: {
    sendRelated (item) {
      item.type = item.base_class
      this.$emit('select', item)
    }
  }
}
</script>

<template>
  <fieldset>
    <legend>Related</legend>
    <switch-component
      :options="tabOptions"
      v-model="view"
      name="related"/>

    <smart-selector
      v-if="otuView"
      model="otus"
      target="BiologicalAssociation"
      buttons
      inline
      @selected="sendRelated"
    />
    <smart-selector
      v-else
      model="collection_objects"
      target="BiologicalAssociation"
      buttons
      inline
      @selected="sendRelated"
    />
  </fieldset>
</template>

<script>

import SwitchComponent from '../shared/switch.vue'
import SmartSelector from 'components/ui/SmartSelector.vue'
import CRUD from '../../request/crud'

export default {
  mixins: [CRUD],

  components: {
    SwitchComponent,
    SmartSelector
  },

  emits: ['select'],

  computed: {
    otuView () {
      return this.view === 'otu'
    }
  },

  data () {
    return {
      view: 'otu',
      tabOptions: ['otu', 'collection object']
    }
  },

  methods: {
    sendRelated (item) {
      this.$emit('select', {
        ...item,
        type: item.base_class
      })
    }
  }
}
</script>

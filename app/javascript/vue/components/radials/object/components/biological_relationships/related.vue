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
      otu-picker
      :autocomplete="false"
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

const TAB = {
  otu: 'otu',
  collectionObject: 'collection object'
}

export default {
  mixins: [CRUD],

  components: {
    SwitchComponent,
    SmartSelector
  },

  emits: ['select'],

  computed: {
    otuView () {
      return this.view === TAB.otu
    }
  },

  data () {
    return {
      view: TAB.otu,
      tabOptions: Object.values(TAB)
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

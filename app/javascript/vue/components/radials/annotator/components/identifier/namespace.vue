<template>
  <fieldset>
    <legend>Namespace</legend>
    <smart-selector
      class="margin-medium-top"
      model="namespaces"
      klass="CollectionObject"
      pin-section="Namespaces"
      pin-type="Namespace"
      @selected="setNamespace"/>
  </fieldset>
</template>

<script>

import CRUD from '../../request/crud.js'
import SmartSelector from 'components/smartSelector'

export default {
  mixins: [CRUD],
  components: {
    SmartSelector
  },
  props: {
    objectType: {
      type: String,
      required: true
    },
    value: {
    }
  },
  data () {
    return {
      namespace_id: undefined
    }
  },
  methods: {
    setNamespace (value) {
      this.$emit('onLabelChange', (value.hasOwnProperty('label') ? value.label : value.short_name))
      this.$emit('input', value.id)
    }
  }
  }
</script>

<template>
  <fieldset>
    <legend>Catalogue numbers</legend>
    <smart-selector
    model="namespaces"
    klass="CollectionObject"/>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/smartSelector'

export default {
  components: {
    SmartSelector
  },
  data () {
    return {
      tabs: [],
      lists: undefined,
      view: undefined
    }
  },
  methods: {

  }
}
</script>

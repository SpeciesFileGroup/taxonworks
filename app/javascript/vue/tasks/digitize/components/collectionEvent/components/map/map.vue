<template>
  <div>

  </div>
</template>

<script>

import GetterNames from '../../../../store/getters/getters.js'

export default {
  computed: {
    latitude() {
      return this.$store.getters[GetterNames.GetCollectionEvent].latitude
    },
    longitude() {
      return this.$store.getters[GetterNames.GetCollectionEvent].longitude
    }
  }
}
</script>

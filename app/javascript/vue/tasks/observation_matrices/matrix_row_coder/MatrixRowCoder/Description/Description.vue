<template>
  <div>
    <h3>Description (generated)</h3>
    <span>{{ description }}</span>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'

export default {
  computed: {
    description () {
      return this.$store.getters[GetterNames.GetDescription]?.generated_description
    }
  }
}
</script>

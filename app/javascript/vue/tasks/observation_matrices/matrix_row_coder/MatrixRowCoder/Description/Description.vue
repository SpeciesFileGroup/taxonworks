<template>
  <div>
    <h2>Description</h2>
    <p>{{ description }}</p>
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

<template>
  <div class="panel content new-combination-box"/>
</template>

<script>

import { GetLastCombinations } from '../request/resources'

export default {
  data: function () {
    return {
      combinations: []
    }
  },
  methods: {
    getCombinations () {
      GetLastCombinations().then(response => {
        this.combinations = response.body
      })
    }
  }
}
</script>

<template>
  <div class="panel content separate-bottom">
    <div class="flex-separate middle">
      <span>
        JSON Request: {{ URLRequest }}
      </span>
    </div>
  </div>
</template>

<script>
import { GetterNames } from '../store/getters/getters'

export default {
  computed: {
    URLRequest () {
      return this.$store.getters[GetterNames.GetURLRequest]
    }
  }
}
</script>

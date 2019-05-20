<template>
  <div>
    <ul class="context-menu">
      <li>
        <label>
          <input type="checkbox">
          OTU
        </label>
      </li>
      <li>
        <label>
          <input type="checkbox">
          Collection object
        </label>
      </li>
      <li>
        <label>
          <input type="checkbox">
          Extract
        </label>
      </li>
    </ul>
    <smart-selector
      v-model="view"
      :options="tabs">
  </div>
</template>

<script>

import SmartSelector from 'components/switch'

export default {
  components: {
    SmartSelector
  },
  data () {
    return {
      otu: false,
      co: false,
      extract: false,
      lists: [],
      tabs: [],
      view: undefined
    }
  }
}
</script>

<style>

</style>

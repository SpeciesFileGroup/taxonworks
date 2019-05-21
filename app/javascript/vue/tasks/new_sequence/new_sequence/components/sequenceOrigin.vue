<template>
  <div>
    <h2>Sequence origin</h2>
    <smart-selector
      v-model="view"
      :options="tabs"
    />
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
      :options="tabs"/>
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
      tabs: ['search'],
      view: undefined
    }
  }
}
</script>

<style>

</style>

<template>
  <div>
    <h1>Filter nomenclature</h1>
    <div class="horizontal-left-content align-start">
      <filter-component @result="list = $event"/>
      <list-component :list="list"/>
    </div>
  </div>
</template>

<script>

import FilterComponent from './components/filter.vue'
import ListComponent from './components/list'

export default {
  components: {
    FilterComponent,
    ListComponent
  },
  data() {
    return {
      list: [],
    }
  }
}
</script>

<style>

</style>

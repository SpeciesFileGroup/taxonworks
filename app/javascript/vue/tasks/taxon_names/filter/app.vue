<template>
  <div>
    <div class="flex-separate middle">
      <h1>Filter nomenclature</h1>
      <div>
        <label>
          <input
            type="checkbox"
            v-model="activeFilter">
          Show filter
        </label>
      </div>
    </div>
    <div class="horizontal-left-content align-start">
      <filter-component
        class="separate-right"
        v-show="activeFilter"
        @result="list = $event"/>
      <list-component
        :class="{ 'separate-left': activeFilter }"
        :list="list"/>
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
      activeFilter: true
    }
  }
}
</script>

<style>

</style>

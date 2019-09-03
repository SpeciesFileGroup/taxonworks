<template>
  <div>
    <div class="flex-separate middle">
      <h1>Observation matrices dashboard</h1>
      <ul class="context-menu">
        <li>
          <label>
            <input
              type="checkbox"
              v-model="activeFilter">
            Show filter
          </label>
        </li>
      </ul>
    </div>

    <div class="horizontal-left-content align-start">
      <filter-component
        class="separate-right"
        v-show="activeFilter"
        @result="loadList"
        @reset="resetTask"/>
      <div class="full_width">
        <!-- List here -->
        <h3
          v-if="!list.length"
          class="subtle middle horizontal-center-content">No records found.
        </h3>
      </div>
    </div>
  </div>
</template>

<script>

import FilterComponent from './components/filter.vue'

export default {
  components: {
    FilterComponent
  },
  data () {
    return {
      list: [],
      activeFilter: true
    }
  },
  methods: {
    resetTask () {
      this.list = []
    },
    loadList (newList) {
      this.list = newList
    }
  }
}
</script>

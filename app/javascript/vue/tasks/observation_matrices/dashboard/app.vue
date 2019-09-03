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
        @urlRequest="urlRequest = $event"
        @result="loadList"
        @reset="resetTask"/>
      <div class="full_width">
        <!-- List here -->
        <h3
          v-if="alreadySearch && !list.length"
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
      urlRequest: '',
      activeFilter: true,
      activeJSONRequest: false,
      append: false,
      alreadySearch: false,
    }
  },
  methods: {
    resetTask () {
      this.alreadySearch = false
      this.list = []
      this.urlRequest = ''
    },
    loadList (newList) {
      if (this.append) {
        let concat = newList.concat(this.list)
              
        concat = concat.filter((item, index, self) =>
          index === self.findIndex((i) => (
            i.id === item.id
          ))
        )
        this.list = concat
      }
      else {
        this.list = newList
      }
      this.alreadySearch = true
    }
  }
}
</script>

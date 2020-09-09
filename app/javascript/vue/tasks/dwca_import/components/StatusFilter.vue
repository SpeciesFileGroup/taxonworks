<template>
  <th class="position-sticky column-filter">
    <div class="flex-separate middle">
      Status
      <div class="margin-small-left">
        <button
          class="button"
          :disabled="disabled"
          :class="{
            'button-data': applied,
            'button-default': !applied
          }"
          @click="show = !show"
        >
          ▼
        </button>
      </div>
    </div>
    <div
      v-if="show && !disabled"
      class="panel content filter-container"
    >
      <ul class="no_bullets">
        <li
          class="horizontal-left-content"
          v-for="filter in options"
          :key="filter"
        >
          <label>
            <input
              type="checkbox"
              :value="filter"
              v-model="filters"
            >
            {{ filter }}
          </label>
        </li>
      </ul>
    </div>
  </th>
</template>

<script>

import FilterStatus from '../const/importColors'

export default {
  props: {
    value: {
      type: Array,
      required: true
    },
    disabled: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    filters: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    },
    applied () {
      return this.value.length
    }
  },
  data () {
    return {
      options: Object.keys(FilterStatus),
      show: false
    }
  }
}
</script>

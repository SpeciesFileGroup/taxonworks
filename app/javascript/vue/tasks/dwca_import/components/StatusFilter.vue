<template>
  <th class="position-sticky column-filter">
    <div class="flex-separate middle">
      Status
      <div>
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

import FilterStatus from '../const/filterStatus'

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
      options: FilterStatus(),
      show: false
    }
  }
}
</script>

<style lang="scss" scoped>
  .column-filter {
    position: relative;

    .filter-container {
      display: none;
      min-width: 200px;
      left:0;
      position: absolute;
    }
  }
  .column-filter:hover {
    .filter-container {
      display: flex;
    }
  }
</style>

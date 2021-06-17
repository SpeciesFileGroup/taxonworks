<template>
  <th class="position-sticky column-filter">
    <div class="flex-separate middle">
      Status
      <div class="margin-small-left">
        <button
          class="button"
          :disabled="disabled"
          :class="[applied.length
            ? 'button-data'
            : 'button-default'
          ]"
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
          v-for="option in options"
          :key="option"
        >
          <label>
            <input
              type="checkbox"
              :value="option"
              v-model="filter"
            >
            {{ option }}
          </label>
        </li>
      </ul>
    </div>
  </th>
</template>

<script>

import FilterStatus from '../const/importColors'
import ColumnMixin from './shared/columnMixin.js'

export default {
  mixins: [ColumnMixin],

  props: {
    disabled: {
      type: Boolean,
      default: false
    }
  },

  data () {
    return {
      options: Object.keys(FilterStatus)
    }
  }
}
</script>

<template>
  <table>
    <thead>
      <tr class="cell-head">
        <th>{{ header[0] }}</th>
        <th>{{ header[1] }}</th>
      </tr>
    </thead>
    <tbody>
      <template
        v-for="(value, key) in items"
        :key="key"
      >
        <tr
          v-if="value"
          :[getFilterAttribute(key)]="value"
        >
          <td v-html="key" />
          <td
            class="cell-value"
            v-html="value"
          />
        </tr>
      </template>
    </tbody>
  </table>
</template>

<script setup>
import { DATA_ATTRIBUTE_FILTER_PROPERTY } from 'constants/index.js'

const props = defineProps({
  items: {
    type: Object,
    required: true
  },

  header: {
    type: Array,
    default: () => ['Field', 'Value']
  },

  filterAttributes: {
    type: Boolean,
    default: false
  }
})

const getFilterAttribute = (atrr) => props.filterAttributes && `${DATA_ATTRIBUTE_FILTER_PROPERTY}-${atrr}`
</script>

<style scoped>
table {
  box-shadow: none;
}

tr {
  border-bottom: 1px solid #eaeaea;
}

th {

  border-bottom: 2px solid #eaeaea;
}
.cell-value {
  font-weight: 500;
  word-break: break-all;
}

.cell-head {
  text-transform: uppercase;
}
</style>

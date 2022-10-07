<template>
  <table>
    <thead>
      <tr class="cell-head">
        <th>{{ header[0] }}</th>
        <th>
          {{ header[1] }}
        </th>
      </tr>
    </thead>
    <tbody>
      <template
        v-for="(value, key) in items"
        :key="key"
      >
        <tr v-if="value">
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
defineProps({
  items: {
    type: Object,
    required: true
  },
  header: {
    type: Array,
    default: () => ['Field', 'Value']
  }
})
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

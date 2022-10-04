<template>
  <table>
    <thead>
      <tr class="cell-head">
        <th>Field</th>
        <th>Value</th>
      </tr>
    </thead>
    <tbody>
      <template
        v-for="(value, key) in items"
        :key="key"
      >
        <tr v-if="value">
          <td>{{ key }}</td>
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
}

.cell-head {
  font-weight: 200;
  text-transform: uppercase;
}
</style>

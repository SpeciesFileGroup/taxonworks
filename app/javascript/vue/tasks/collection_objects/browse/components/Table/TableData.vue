<template>
  <table>
    <thead>
      <tr>
        <th
          v-for="item in headers"
          :key="item"
        >
          {{ item }}
        </th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="(properties, index) in items"
        :key="index"
      >
        <td
          v-for="(value, key) in properties"
          :key="key"
          v-html="value"
        />
      </tr>
    </tbody>
  </table>
</template>

<script setup>
defineProps({
  headers: {
    type: Array,
    default: () => []
  },

  items: {
    type: Array,
    default: () => []
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
  text-transform: uppercase;

}

</style>

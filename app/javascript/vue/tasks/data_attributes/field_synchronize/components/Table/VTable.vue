<template>
  <table
    class="table-striped full_width"
    border="1"
  >
    <thead>
      <tr>
        <th
          v-for="attr in attributes"
          :key="attr"
        >
          {{ attr }}
        </th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in list"
        :key="item.id"
      >
        <td
          v-for="attr in attributes"
          :key="attr"
        >
          {{ item[attr] }}
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
const props = defineProps({
  attributes: {
    type: Array,
    default: () => []
  },

  list: {
    type: Array,
    default: () => []
  }
})
</script>

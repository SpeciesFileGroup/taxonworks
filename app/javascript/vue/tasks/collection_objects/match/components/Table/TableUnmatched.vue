<template>
  <table class="table-striped full_width">
    <thead>
      <tr>
        <th class="w-2"></th>
        <th>Match</th>
        <th>Collection object</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="data in list"
        :key="identifier"
      >
        <td></td>
        <td>{{ data.identifier }}</td>
        <td>Unmatched</td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
const props = defineProps({
  list: {
    type: Array,
    required: true
  }
})
</script>

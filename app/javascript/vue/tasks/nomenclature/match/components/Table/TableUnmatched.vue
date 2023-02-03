<template>
  <table class="table-striped">
    <thead>
      <tr>
        <th>Unmatched</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="unmatched in list"
        :key="unmatched"
      >
        <td>{{ unmatched }}</td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>

defineProps({
  list: {
    type: Array,
    required: true
  }
})
</script>

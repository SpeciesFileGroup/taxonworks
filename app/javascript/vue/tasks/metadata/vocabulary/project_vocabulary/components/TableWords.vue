<template>
  <table class="table-striped">
    <thead>
      <tr>
        <th>Term</th>
        <th>Count</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="[term, count] in list"
        :key="term"
      >
        <td v-text="term" />
        <td v-text="count" />
      </tr>
    </tbody>
  </table>
</template>

<script setup>
defineProps({
  list: {
    type: Array,
    default: () => []
  }
})
</script>

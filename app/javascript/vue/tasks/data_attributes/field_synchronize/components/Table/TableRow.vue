<template>
  <tr>
    <td
      v-for="(value, key) in item"
      :key="key"
    >
      {{ value }}
    </td>
  </tr>
</template>

<script setup>
defineProps({
  item: {
    type: Object,
    required: true
  }
})
</script>

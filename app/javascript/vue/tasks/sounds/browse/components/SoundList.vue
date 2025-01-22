<template>
  <table>
    <thead>
      <tr>
        <th></th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="sound in sounds"
        :key="sound.id"
      >
        <td>{{ sound.name }}</td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
const props = defineProps({
  sounds: {
    type: Array,
    default: () => []
  }
})
</script>

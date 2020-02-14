<template>
  <tr>
    <td v-for="column in row">
      {{ column }}
    </td>
  </tr>
</template>

<script>
export default {
  props: {
    row: {
      type: Array,
      required: true
    }
  }
}
</script>

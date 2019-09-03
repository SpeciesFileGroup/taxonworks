<template>
  <table>
    <thead>
      <tr>
        <th v-for="rank in ranks">{{ rank }}</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td></td>
      </tr>
    </tbody>
  </table>
</template>

<script>
export default {
  props: {
    ranks: {
      type: Array,
      default: () => { return [] }
    }
  }
}
</script>

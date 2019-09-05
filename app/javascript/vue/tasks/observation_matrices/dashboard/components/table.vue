<template>
  <table v-if="tableRanks">
    <thead>
      <tr>
        <th v-for="rank in tableRanks.column_headers">{{ rank }}</th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="row in tableRanks.data">
        <td v-for="data in row">
          {{ data }}
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script>
export default {
  props: {
    tableRanks: {
      type: Object,
      default: () => { return {} }
    }
  }
}
</script>

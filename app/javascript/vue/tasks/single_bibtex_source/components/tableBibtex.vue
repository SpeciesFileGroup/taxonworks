<template>
  <table>
    <tbody>
      <tr 
        v-for="(value, key) in bibtex"
        class="contextMenuCells"
        :key="key">
        <td>{{ key | capitalize | humanize }}</td>
        <td>{{ value }}</td>
      </tr>
    </tbody>
  </table>
</template>

<script>
export default {
  props: {
    bibtex: {
      type: Object,
      required: true
    }
  },
  filters: {
    capitalize: function (value) {
      if (!value) return ''
      value = value.toString()
      return value.charAt(0).toUpperCase() + value.slice(1)
    },
    humanize: (value) => {
      return (typeof value == 'string' ? value.replace(/[_]/gm, " ") : value)
    }
  },
}
</script>

<style>

</style>

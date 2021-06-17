<template>
  <table>
    <tbody>
      <tr
        v-for="(value, key) in bibtex"
        class="contextMenuCells"
        :key="key">
        <td>{{ humanize(capitalize(key)) }}</td>
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

  methods: {
    capitalize (value) {
      if (!value) return ''
      value = value.toString()
      return value.charAt(0).toUpperCase() + value.slice(1)
    },

    humanize (value) {
      return (typeof value === 'string' ? value.replace(/[_]/gm, " ") : value)
    }
  }
}
</script>

<template>
  <div>
    <h3>{{ title }}</h3>
    <table>
      <tbody>
        <tr
          v-for="(item, index) in list"
          class="contextMenuCells"
          :class="{ even: (index % 2 == 0) }">
          <td class="column-property">{{ item.role_object_type }}</td>
          <td class="column-person">{{ item.role_object_tag }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
export default {
  props: {
    list: {
      type: Array,
      default: () => { return [] }
    },
    title: {
      type: String,
      required: true
    }
  }
}
</script>

<style scoped>
  .column-property {
    min-width: 100px;
  }
</style>

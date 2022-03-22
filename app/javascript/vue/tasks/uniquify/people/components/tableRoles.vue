<template>
  <div>
    <h3>{{ title }}</h3>
    <table>
      <tbody>
        <tr
          v-for="(item, index) in list"
          :key="item.id"
          class="contextMenuCells"
          :class="{ even: (index % 2 === 0) }"
        >
          <td class="column-property">
            {{ item.role_object_type }}
          </td>
          <td class="column-person">
            {{ item.object_tag }}
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
const props = defineProps({
  list: {
    type: Array,
    default: () => []
  },
  title: {
    type: String,
    required: true
  }
})
</script>

<style scoped>
  .column-property {
    min-width: 100px;
  }
</style>

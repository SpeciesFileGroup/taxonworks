<template>
  <table class="full_width">
    <thead>
      <tr>
        <th>Subject</th>
        <th :colspan="5" />
        <td />
        <th>Object</th>
        <th :colspan="6" />
      </tr>
      <tr>
        <th>Related</th>
        <th>Order</th>
        <th>Family</th>
        <th>Genus</th>
        <th>Object tag</th>
        <th>Biological properties</th>

        <th>Biological relationship</th>

        <th>Biological properties</th>
        <th>Related</th>
        <th>Order</th>
        <th>Family</th>
        <th>Genus</th>
        <th>Citations</th>
      </tr>
    </thead>
    <tbody>
      <BiologicalAssociationRow
        v-for="row in list"
        :key="row.id"
        :row="row"
      />
    </tbody>
  </table>
</template>

<script setup>
import BiologicalAssociationRow from './BiologicalAssociationRow.vue'

defineProps({
  list: {
    type: Array,
    default: () => []
  }
})
</script>

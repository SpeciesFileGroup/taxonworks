<template>
  <table class="full_width table-striped table-cell-border">
    <thead>
      <tr>
        <th class="w-2" />
        <th class="table-cell-border-left-thick">Subject</th>
        <th :colspan="5" />
        <th class="table-cell-border-left-thick" />
        <th class="table-cell-border-left-thick">Object</th>
        <th :colspan="6" />
      </tr>
      <tr class="table-header-border table-header-bold">
        <th class="w-2" />
        <th class="table-cell-border-left-thick">Related</th>
        <th>Order</th>
        <th>Family</th>
        <th>Genus</th>
        <th>Label</th>
        <th>Biological properties</th>

        <th class="table-cell-border-left-thick">Biological relationship</th>

        <th class="table-cell-border-left-thick">Biological properties</th>
        <th>Related</th>
        <th>Order</th>
        <th>Family</th>
        <th>Genus</th>
        <th>Label</th>
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

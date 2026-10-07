<template>
  <table class="full_width table-striped table-cell-border">
    <thead>
      <tr>
        <th class="w-2" />
        <th class="table-cell-border-left-thick">Subject</th>
        <th :colspan="showRanks ? 4 : 1" />
        <th class="table-cell-border-left-thick" />
        <th class="table-cell-border-left-thick">Object</th>
        <th :colspan="showRanks ? 4 : 1" />
        <th
          :colspan="2"
          class="table-cell-border-left-thick"
        />
      </tr>
      <tr class="table-header-border table-header-bold">
        <th class="w-2" />
        <template v-if="showRanks">
          <th>Order</th>
          <th>Family</th>
          <th>Genus</th>
        </template>
        <th>Label</th>
        <th>Biological properties</th>

        <th class="table-cell-border-left-thick">Biological relationship</th>

        <th class="table-cell-border-left-thick">Biological properties</th>
        <template v-if="showRanks">
          <th>Order</th>
          <th>Family</th>
          <th>Genus</th>
        </template>
        <th>Label</th>
        <th class="table-cell-border-left-thick">Citations</th>
        <th>Tags</th>
      </tr>
    </thead>
    <tbody>
      <PanelBiologicalAssociationsRow
        v-for="row in list"
        :key="row.id"
        :row="row"
        :show-ranks="showRanks"
        @open-detail="emit('open-detail', $event)"
      />
    </tbody>
  </table>
</template>

<script setup>
import PanelBiologicalAssociationsRow from './PanelBiologicalAssociationsRow.vue'

defineProps({
  list: {
    type: Array,
    default: () => []
  },

  showRanks: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['open-detail'])
</script>

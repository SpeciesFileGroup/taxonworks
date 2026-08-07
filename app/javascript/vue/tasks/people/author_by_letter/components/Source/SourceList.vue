<template>
  <div>
    <table id="source-table">
      <thead>
        <tr>
          <th>Source</th>
          <th />
        </tr>
      </thead>
      <SourceRow
        v-for="src in list"
        :key="src.id"
        :source="src"
      />
    </table>
    <span v-if="list.length"> {{ list.length }} sources </span>
  </div>
</template>

<script setup>
import SourceRow from './SourceRow.vue'

defineProps({
  list: {
    type: Array,
    required: true
  }
})
</script>

<template>
  <div class="panel content">
    <h3>Depictions</h3>
    <TableDepicted :records="store.depictionObjects" />
  </div>
</template>

<script setup>
import TableDepicted from '../Table/TableDepicted.vue'
import useStore from '../../store/store.js'

const store = useStore()
</script>

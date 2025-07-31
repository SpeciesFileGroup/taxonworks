<template>
  <div class="field label-above">
    <label>Total</label>
    <input
      v-model.number="store.collectionObject.total"
      type="number"
    />
  </div>
</template>

<script setup>
import useStore from '../../store/store.js'

const store = useStore()
</script>

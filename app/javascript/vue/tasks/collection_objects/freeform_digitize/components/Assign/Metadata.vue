<template>
  <div>
    <label>
      <input
        type="checkbox"
        v-model="store.isMetadataDepiction"
      />
      Is metadata depiction
    </label>
  </div>
</template>

<script setup>
import useStore from '../../store/store.js'
const store = useStore()
</script>

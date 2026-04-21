<template>
  <textarea
    v-model="store.source.verbatim"
    @change="() => (store.source.isUnsaved = true)"
  />
</template>

<script setup>
import { useSourceStore } from '../../store'

const store = useSourceStore()
</script>

<style scoped>
textarea {
  width: 100%;
  height: 100px;
}
</style>

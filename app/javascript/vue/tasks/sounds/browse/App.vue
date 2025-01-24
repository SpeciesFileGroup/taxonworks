<template>
  <div id="app-container">
    <h1>Browse sound</h1>
  </div>
</template>

<script setup>
import useStore from './store/store.js'
import { ref, onBeforeMount } from 'vue'
import { URLParamsToJSON } from '@/helpers'

const store = useStore()

onBeforeMount(() => {
  const params = URLParamsToJSON(window.location.href)
  const soundId = params.sound_id

  if (soundId) {
    store.loadSound(soundId)
  }
})
</script>

<style scoped>
#app-container {
  width: 1240px;
}
</style>

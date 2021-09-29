<template>
  <div>
    <h1>Matrix column coder</h1>
  </div>
</template>

<script setup>
import { useStore } from 'vuex'
import { onBeforeMount } from 'vue'
import { ActionNames } from './store/actions/actions.js'

const store = useStore()

onBeforeMount(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const columnId = urlParams.get('observation_matrix_column_id')

  if (/^\d+$/.test(columnId)) {
    console.log("entra")
    store.dispatch(ActionNames.LoadColumns, columnId)
  }
})
</script>

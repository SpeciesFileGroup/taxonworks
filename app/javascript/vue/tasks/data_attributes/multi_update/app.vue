<template>
  <h1>Multi update</h1>
</template>

<script setup>
import { onBeforeMount } from 'vue'
import { useQueryParam } from '../field_synchronize/composables'
import useStore from './store/store'

const store = useStore()
const { queryParam, queryValue } = useQueryParam()

onBeforeMount(() => {
  store.loadObjects({ queryParam, queryValue })
})
</script>

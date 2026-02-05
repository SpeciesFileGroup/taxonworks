<template>
  <VNavbar>
    <div>
      <span class="capitalize">{{ store.taxonName?.rank }}</span>
      <h1 v-html="otu.object_tag" />
    </div>
  </VNavbar>
</template>

<script setup>
import { useOtuStore } from '../store'
import VNavbar from '@/components/layout/NavBar.vue'

const store = useOtuStore()
</script>

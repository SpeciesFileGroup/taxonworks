<template>
  <div class="panel content">
    <h2>Identifiers</h2>
  </div>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters'

const store = useStore()
const identifier = computed(() => store.dispatch(GetterNames.GetIdentifier))
</script>

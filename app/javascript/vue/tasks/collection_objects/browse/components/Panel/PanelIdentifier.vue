<template>
  <div class="panel panel__content">
    <h2 class="panel__title">Identifiers</h2>
    <ul class="no_bullets">
      <li
        v-for="identifier in identifiers"
        :key="identifier.id"
        v-html="identifier.objectTag"
      />
    </ul>
  </div>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters'

const store = useStore()
const identifiers = computed(() => store.getters[GetterNames.GetIdentifiers])
</script>

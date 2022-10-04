<template>
  <div class="panel panel__content">
    <h3 class="panel__title">
      Dwc
    </h3>
    <TableAttributes :items="dwcItems" />
  </div>
</template>

<script setup>
import TableAttributes from '../Table/TableAttributes.vue'
import { computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters';

const store = useStore()

const dwcItems = computed(() => store.getters[GetterNames.GetDwc])
</script>
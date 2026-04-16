<template>
  <fieldset>
    <legend>Biocurations</legend>
    <FormBiocuration
      v-model="biocurationStore.list"
      :biocurations-groups="biocurationStore.biocurationGroups"
      @add="biocurationStore.add"
      @remove="biocurationStore.remove"
    />
  </fieldset>
</template>

<script setup>
import { onBeforeMount } from 'vue'
import useBiocurationStore from '@/tasks/field_occurrences/new/store/biocurations.js'
import FormBiocuration from '@/components/Form/FormBiocuration.vue'

const biocurationStore = useBiocurationStore()

onBeforeMount(() => {
  biocurationStore.loadBiocurationGroups()
})
</script>

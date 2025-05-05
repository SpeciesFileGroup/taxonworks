<template>
  <BlockLayout>
    <template #header>
      <h3>Biocurations</h3>
    </template>
    <template #options>
      <VLock v-model="settings.locked.biocurations" />
    </template>
    <template #body>
      <FormBiocuration
        v-model="biocurationStore.list"
        :biocurations-groups="biocurationStore.biocurationGroups"
        @add="biocurationStore.add"
        @remove="biocurationStore.remove"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import FormBiocuration from '@/components/Form/FormBiocuration.vue'
import useBiocurationStore from '../store/biocurations.js'
import useSettings from '../store/settings.js'
import VLock from '@/components/ui/VLock/index.vue'

const biocurationStore = useBiocurationStore()
const settings = useSettings()

biocurationStore.loadBiocurationGroups()
</script>

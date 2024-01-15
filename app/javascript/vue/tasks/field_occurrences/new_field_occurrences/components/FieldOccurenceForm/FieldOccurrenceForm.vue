<template>
  <BlockLayout>
    <template #header>
      <h3>Field occurrence</h3>
    </template>
    <template #body>
      <div class="flex-col gap-medium">
        <FieldTotal v-model="store.fieldOccurrence" />
        <FieldAbsent v-model="store.fieldOccurrence" />
        <BiocurationForm
          :object-id="store.fieldOccurrence.id"
          :biocurations-groups="biocurationStore.biocurationGroups"
        />
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import FieldAbsent from './FieldIsAbsent.vue'
import FieldTotal from './FieldTotal.vue'
import BiocurationForm from '../BiocurationForm.vue'
import useStore from '../../store/store.js'
import useBiocurationStore from '../../store/biocurations.js'

const store = useStore()
const biocurationStore = useBiocurationStore()

biocurationStore.loadBiocurationGroups()
</script>

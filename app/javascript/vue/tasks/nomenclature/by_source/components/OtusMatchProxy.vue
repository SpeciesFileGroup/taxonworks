<template>
  <div>
    <div class="flex-separate middle">
      <h2>OTU summary</h2>
      <VBtn
        color="primary"
        medium
        :disabled="!depictions.length"
        @click="isDepictionsModalVisible = true"
      >
        Show all depictions ({{ depictions.length }})
      </VBtn>
    </div>
    <DepictionsModal
      v-if="isDepictionsModalVisible"
      :otus="list"
      :depictions-by-otu="depictionsByOtu"
      @close="isDepictionsModalVisible = false"
    />
    <VSpinner v-if="isLoading" />
    <TableOtu
      class="full_width"
      :list="list"
      :depictions-by-otu="depictionsByOtu"
    />
  </div>
</template>
<script setup>

import { useStore } from 'vuex'
import { computed, ref } from 'vue'
import { GetterNames } from '../store/getters/getters'
import TableOtu from './Table/TableOtu.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import DepictionsModal from './DepictionsModal.vue'
import useOtuDepictions from '../composables/useOtuDepictions'

const store = useStore()
const list = computed(() => store.getters[GetterNames.GetOtuList])
const isDepictionsModalVisible = ref(false)
const { depictions, depictionsByOtu, isLoading } = useOtuDepictions(list)

</script>

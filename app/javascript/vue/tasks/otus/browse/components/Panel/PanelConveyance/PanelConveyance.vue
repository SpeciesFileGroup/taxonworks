<template>
  <PanelLayout
    :status="status"
    :title="title"
    :spinner="isLoading"
  >
    <table
      v-if="conveyances.length"
      class="full_width table-striped"
    >
      <tbody>
        <PanelConveyanceRow
          v-for="conveyance in conveyances"
          :key="conveyance.id"
          :conveyance="conveyance"
        />
      </tbody>
    </table>
  </PanelLayout>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Conveyance } from '@/routes/endpoints'
import PanelLayout from '../PanelLayout.vue'
import PanelConveyanceRow from './PanelConveyanceRow.vue'

const props = defineProps({
  otu: {
    type: Object,
    required: true
  },

  otus: {
    type: Array,
    required: true
  },

  status: {
    type: String,
    default: 'unknown'
  },

  title: {
    type: String,
    default: 'Sounds'
  }
})

const conveyances = ref([])
const isLoading = ref(false)

async function loadConveyances(otus) {
  isLoading.value = true

  try {
    const otuIds = otus.map((o) => o.id)
    const { body } = await Conveyance.where({
      otu_id: otuIds,
      otu_scope: ['all'],
      per: 500
    })

    conveyances.value = body
  } catch {
  } finally {
    isLoading.value = false
  }
}

watch(
  () => props.otus,
  (newVal) => {
    if (newVal.length > 0) {
      loadConveyances(newVal)
    }
  },
  { immediate: true }
)
</script>

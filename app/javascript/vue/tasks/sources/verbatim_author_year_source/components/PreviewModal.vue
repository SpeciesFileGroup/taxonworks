<template>
  <Modal
    @close="$emit('close')"
    container-style="max-width: 600px;"
  >
    <template #header>
      <h3>{{ author }} {{ year }}</h3>
    </template>
    <template #body>
      <VSpinner
        v-if="isLoading"
        legend="Loading TaxonNames..."
      />
      <div v-else-if="taxonNames.length === 0">
        <p>No TaxonNames found.</p>
      </div>
      <table
        v-else
        class="full_width"
      >
        <thead>
          <tr>
            <th>Name</th>
            <th>Author</th>
            <th>Year</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="taxonName in taxonNames"
            :key="taxonName.id"
          >
            <td>
              {{
                taxonName.cached ||
                taxonName.name ||
                `TaxonName #${taxonName.id}`
              }}
            </td>
            <td>{{ taxonName.verbatim_author || '' }}</td>
            <td>{{ taxonName.year_of_publication || '' }}</td>
          </tr>
        </tbody>
      </table>
    </template>
  </Modal>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import useStore from '../store/store'
import Modal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const props = defineProps({
  author: {
    type: String,
    required: true
  },
  year: {
    type: [Number, String],
    required: true
  }
})

defineEmits(['close'])

const store = useStore()
const taxonNames = ref([])
const isLoading = ref(false)

onMounted(async () => {
  isLoading.value = true
  try {
    taxonNames.value = await store.loadPreviewTaxonNames(
      props.author,
      props.year
    )
  } catch (error) {
    TW.workbench.alert.create('Error loading TaxonNames', 'error')
  } finally {
    isLoading.value = false
  }
})
</script>

<style scoped>
table {
  border-collapse: collapse;
}

th,
td {
  padding: 8px;
  text-align: left;
}

th {
  background-color: var(--table-row-bg-odd);
}

td {
  border-bottom: 1px solid var(--border-color);
}
</style>

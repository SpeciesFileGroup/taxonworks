<template>
  <VModal
    @close="$emit('close')"
    :container-style="{ width: '900px' }"
  >
    <template #header>
      <h3>{{ author }} {{ year }} — page numbers</h3>
    </template>
    <template #body>
      <VSpinner
        v-if="isLoading"
        legend="Loading..."
      />
      <template v-else>
        <div
          v-if="source"
          class="margin-medium-bottom"
        >
          <span v-html="source.cached" />
          &nbsp;—&nbsp;
          <a
            :href="`${RouteNames.NewSource}?source_id=${source.id}`"
            target="_blank"
          >
            View source
          </a>
        </div>

        <div v-if="rows.length === 0">
          <p>No citations found.</p>
        </div>
        <table
          v-else
          class="full_width"
        >
          <thead>
            <tr>
              <th>Name</th>
              <th>Pages</th>
              <th />
              <th />
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="row in rows"
              :key="row.taxonName.id"
            >
              <td>
                <a
                  :href="`${RouteNames.BrowseNomenclature}?taxon_name_id=${row.taxonName.id}`"
                  target="_blank"
                >
                  {{
                    row.taxonName.cached ||
                    row.taxonName.name ||
                    `TaxonName #${row.taxonName.id}`
                  }}
                </a>
              </td>
              <td>
                <input
                  v-model="row.pages"
                  type="text"
                  class="normal-input inline"
                  placeholder="pages"
                />
              </td>
              <td>
                <VBtn
                  color="submit"
                  medium
                  :disabled="row.isSaving"
                  @click="updatePages(row)"
                >
                  {{ row.isSaving ? 'Saving...' : 'Update' }}
                </VBtn>
              </td>
              <td>
                <SoftValidation
                  v-if="row.citation && row.hasSaved"
                  :key="row.validationKey"
                  :global-id="row.citation.global_id"
                />
              </td>
            </tr>
          </tbody>
        </table>
      </template>
    </template>
  </VModal>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { RouteNames } from '@/routes/routes'
import { TaxonName, Citation, Source } from '@/routes/endpoints'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import SoftValidation from '@/components/soft_validations/objectValidation.vue'

const props = defineProps({
  author: {
    type: String,
    required: true
  },
  year: {
    type: [Number, String],
    required: true
  },
  taxonNameIds: {
    type: Array,
    required: true
  },
  sourceId: {
    type: Number,
    required: true
  }
})

defineEmits(['close'])

const isLoading = ref(false)
const source = ref(null)
const rows = ref([])

onMounted(async () => {
  isLoading.value = true
  try {
    const [namesResponse, citationsResponse, sourceResponse] = await Promise.all([
      TaxonName.where({ taxon_name_id: props.taxonNameIds }),
      Citation.filter({
        citation_object_type: 'TaxonName',
        citation_object_id: props.taxonNameIds,
        source_id: props.sourceId,
        is_original: true
      }),
      Source.find(props.sourceId)
    ])

    source.value = sourceResponse.body

    const citationsByTaxonNameId = {}
    for (const citation of citationsResponse.body) {
      citationsByTaxonNameId[citation.citation_object_id] = citation
    }

    rows.value = namesResponse.body.map((taxonName) => ({
      taxonName,
      citation: citationsByTaxonNameId[taxonName.id],
      pages: citationsByTaxonNameId[taxonName.id]?.pages || '',
      isSaving: false,
      hasSaved: false,
      validationKey: 0
    }))
  } catch {
    TW.workbench.alert.create('Error loading citations', 'error')
  } finally {
    isLoading.value = false
  }
})

async function updatePages(row) {
  if (!row.citation) return
  row.isSaving = true
  try {
    await Citation.update(row.citation.id, { citation: { pages: row.pages } })
    row.hasSaved = true
    row.validationKey++
    TW.workbench.alert.create('Pages updated', 'notice')
  } catch {
    TW.workbench.alert.create('Error updating pages', 'error')
  } finally {
    row.isSaving = false
  }
}
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

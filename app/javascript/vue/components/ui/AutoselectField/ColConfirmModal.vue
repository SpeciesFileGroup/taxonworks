<template>
  <Modal
    :container-style="{ maxWidth: '700px', width: '90vw' }"
    @close="emit('cancel')"
  >
    <template #header>
      <span
        >Catalogue of Life: <strong>{{ ext.col_name }}</strong></span
      >
      <span
        v-if="ext.col_status"
        class="col-confirm-modal__status"
        >{{ ext.col_status }}</span
      >
    </template>

    <template #body>
      <table class="col-confirm-modal__table">
        <thead>
          <tr>
            <th></th>
            <th>Rank</th>
            <th>CoL name</th>
            <th>TaxonWorks match</th>
            <th>Author / Year</th>
            <th>CoL ID</th>
          </tr>
        </thead>
        <tbody>
          <!-- Ancestor rows: distal first (array is proximal→distal, so reversed) -->
          <tr
            v-for="row in ancestorRowsDistalFirst"
            :key="row.col_name + row.rank"
            :class="rowClass(row)"
          >
            <td>
              <input
                v-if="row.match === 'exact'"
                type="checkbox"
                checked
                disabled
              />
              <input
                v-else
                type="checkbox"
                :checked="checkedNames.has(row.col_name)"
                @change="toggleRow(row.col_name)"
              />
            </td>
            <td>{{ row.rank }}</td>
            <td>{{ row.col_name }}</td>
            <td>{{ row.taxonworks_name ?? '—' }}</td>
            <td>{{ row.col_authorship ?? '—' }}</td>
            <td>
              <a
                v-if="row.col_id"
                :href="clbTaxonUrl(row.dataset_id, row.col_id)"
                target="_blank"
                rel="noopener noreferrer"
                >{{ row.col_id }}</a
              >
              <template v-else>—</template>
            </td>
          </tr>

          <!-- Target row — always last, always checked, always disabled -->
          <tr
            class="col-confirm-modal__row--target"
            :class="{ 'col-confirm-modal__row--exact': ext.target_taxonworks_id }"
          >
            <td>
              <input
                type="checkbox"
                checked
                disabled
              />
            </td>
            <td>{{ ext.col_rank }}</td>
            <td>{{ ext.col_name }}</td>
            <td>{{ ext.target_taxonworks_id ? ext.col_name : '—' }}</td>
            <td>{{ ext.col_authorship ?? '—' }}</td>
            <td>
              <a
                v-if="ext.col_key"
                :href="clbTaxonUrl(ext.col_dataset_id, ext.col_key)"
                target="_blank"
                rel="noopener noreferrer"
                >{{ ext.col_key }}</a
              >
              <template v-else>—</template>
            </td>
          </tr>
        </tbody>
      </table>

      <p class="col-confirm-modal__note">
        <template v-if="nothingToCreate">
          All names already exist in TaxonWorks. Click Select to use the existing record.
        </template>
        <template v-else-if="cannotCreate">
          Rank <em>{{ ext.col_rank }}</em> is not supported in TaxonWorks and cannot be created.
        </template>
        <template v-else>
          Checked names without a TaxonWorks match will be created as Protonyms
          with Catalogue of Life identifiers.
        </template>
      </p>
    </template>

    <template #footer>
      <div class="col-confirm-modal__footer">
        <VBtn
          ref="confirmBtn"
          :color="nothingToCreate ? 'default' : 'create'"
          :disabled="isCreating || cannotCreate"
          @click="doConfirm"
          @keydown.enter.prevent="doConfirm"
        >
          {{ nothingToCreate ? 'Select' : (isCreating ? 'Creating…' : 'Create') }}
        </VBtn>
        <button
          class="button circle-button btn-undo button-default"
          :disabled="isCreating"
          title="Cancel — return to search"
          @click="emit('cancel')"
        >
          &#8617;
        </button>
      </div>
    </template>
  </Modal>
</template>

<script setup>
import { ref, computed, onMounted, nextTick } from 'vue'
import Modal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import AjaxCall from '@/helpers/ajaxCall'

const props = defineProps({
  item: { type: Object, required: true }
})

const emit = defineEmits(['confirm', 'cancel'])

// Shorthand for the extension hash
const ext = computed(() => props.item.extension)

// Ancestor rows in distal→proximal order (alignment is proximal→distal, so reverse it)
const ancestorRowsDistalFirst = computed(() =>
  [...(ext.value.alignment ?? [])].reverse()
)

// Set of col_name values the user has checked for creation (match==='none' rows)
const checkedNames = ref(
  new Set(
    (ext.value.alignment ?? [])
      .filter((r) => r.match === 'none')
      .map((r) => r.col_name)
  )
)

// True when nothing needs to be created: target already exists, no ancestor rows are
// checked for creation, and this is a direct TaxonName result (not an OTU hook).
const nothingToCreate = computed(
  () =>
    !ext.value.hook &&
    checkedNames.value.size === 0 &&
    !!ext.value.target_taxonworks_id
)

// True when the target rank is unsupported by TaxonWorks AND no ancestor rows are
// checked — clicking Create would create nothing, so the button should be disabled.
const cannotCreate = computed(
  () =>
    !nothingToCreate.value &&
    checkedNames.value.size === 0 &&
    !!ext.value.target_rank_unknown
)

// Returns a Checklistbank web URL including dataset context, falling back to
// the legacy catalogueoflife.org path when no dataset_id is available.
function clbTaxonUrl(datasetId, taxonId) {
  if (datasetId) {
    return `https://www.checklistbank.org/dataset/${datasetId}/taxon/${taxonId}`
  }
  return `https://www.catalogueoflife.org/data/taxon/${taxonId}`
}

function toggleRow(colName) {
  if (checkedNames.value.has(colName)) {
    checkedNames.value.delete(colName)
  } else {
    checkedNames.value.add(colName)
  }
  // Force reactivity on Set mutation
  checkedNames.value = new Set(checkedNames.value)
}

function rowClass(row) {
  if (row.col_name === errorColName.value)
    return 'col-confirm-modal__row--error'
  return row.match === 'exact' ? 'col-confirm-modal__row--exact' : ''
}

const confirmBtn = ref(null)
const isCreating = ref(false)
const errorColName = ref(null)

onMounted(() => {
  nextTick(() => confirmBtn.value?.$el?.focus())
})

function doConfirm() {
  if (nothingToCreate.value) {
    emit('confirm', {
      id: ext.value.target_taxonworks_id,
      global_id: ext.value.target_global_id ?? null
    })
    return
  }
  doCreate()
}

async function doCreate() {
  if (isCreating.value) return
  isCreating.value = true
  errorColName.value = null

  // Build distal→proximal rows for the server.
  // Exact-match ancestors pass their taxonworks_id so the server uses them as parent anchors.
  // Unchecked none-match ancestors are excluded.
  const ancestorRows = (ext.value.alignment ?? [])
    .slice()
    .reverse() // distal first
    .filter((r) => r.match === 'exact' || checkedNames.value.has(r.col_name))
    .map((r) => ({
      col_name: r.col_name,
      col_rank: r.rank,
      col_id: r.col_id ?? null,
      dataset_id: r.dataset_id ?? null,
      taxonworks_id: r.match === 'exact' ? r.taxonworks_id : null,
      col_authorship: r.col_authorship ?? null,
      col_year: null
    }))

  const targetRow = {
    col_name: ext.value.col_name,
    col_rank: ext.value.col_rank,
    col_id: ext.value.col_key,
    dataset_id: ext.value.col_dataset_id ?? null,
    taxonworks_id: null,
    col_authorship: ext.value.col_authorship ?? null,
    col_year: ext.value.col_year ?? null,
    col_status: ext.value.col_status ?? null
  }

  const createUrl =
    ext.value.hook?.create_url ?? '/taxon_names/autoselect_col_create'
  const yieldsKey = ext.value.hook?.yields ?? 'taxon_name_id'

  try {
    const { body } = await AjaxCall('post', createUrl, {
      rows: [...ancestorRows, targetRow],
      col_code: ext.value.col_code ?? null
    })
    emit('confirm', { id: body[yieldsKey], global_id: body.global_id ?? null })
  } catch (err) {
    errorColName.value = err.response?.body?.failed_col_name ?? null
  } finally {
    isCreating.value = false
  }
}
</script>

<style scoped>
.col-confirm-modal__status {
  margin-left: 8px;
  font-size: 11px;
  opacity: 0.7;
  font-style: italic;
}

.col-confirm-modal__table {
  width: 100%;
  border-collapse: collapse;
  font-size: 12px;
  margin-bottom: 10px;
}

.col-confirm-modal__table th,
.col-confirm-modal__table td {
  border: 1px solid var(--border-color, #ccc);
  padding: 2px 5px;
  text-align: left;
  vertical-align: middle;
}

.col-confirm-modal__table th {
  background: var(--input-bg-color, #f5f5f5);
  font-weight: 600;
}

.col-confirm-modal__row--exact {
  background-color: rgba(0, 128, 0, 0.06);
}

.col-confirm-modal__row--target {
  font-weight: 600;
  border-top: 2px solid var(--border-color, #ccc);
}

.col-confirm-modal__row--error {
  background-color: rgba(200, 0, 0, 0.08);
}

.col-confirm-modal__note {
  font-size: 11px;
  color: var(--text-color-muted, #777);
  margin: 4px 0 0;
}

.col-confirm-modal__error {
  color: var(--color-destroy, #c00);
  font-size: 12px;
  margin-top: 6px;
}

.col-confirm-modal__footer {
  display: flex;
  align-items: center;
  gap: 8px;
}
</style>

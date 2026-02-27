<template>
  <Modal
    :container-style="{ maxWidth: '700px', width: '90vw' }"
    @close="emit('cancel')"
  >
    <template #header>
      <span>Catalog of Life: <strong>{{ ext.col_name }}</strong></span>
      <span v-if="ext.col_status" class="col-confirm-modal__status">{{ ext.col_status }}</span>
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
            <td><code v-if="row.col_id">{{ row.col_id }}</code><template v-else>—</template></td>
          </tr>

          <!-- Target row — always last, always checked, always disabled -->
          <tr class="col-confirm-modal__row--target">
            <td><input type="checkbox" checked disabled /></td>
            <td>{{ ext.col_rank }}</td>
            <td>{{ ext.col_name }}</td>
            <td>—</td>
            <td>{{ ext.col_authorship ?? '—' }}</td>
            <td><code v-if="ext.col_key">{{ ext.col_key }}</code><template v-else>—</template></td>
          </tr>
        </tbody>
      </table>

      <p class="col-confirm-modal__note">
        Checked names without a TaxonWorks match will be created as Protonyms with Catalog of Life identifiers.
      </p>

      <p v-if="errorMessage" class="col-confirm-modal__error">{{ errorMessage }}</p>
    </template>

    <template #footer>
      <div class="col-confirm-modal__footer">
        <button
          ref="confirmBtn"
          class="button button-submit"
          :disabled="isCreating"
          @click="doCreate"
          @keydown.enter.prevent="doCreate"
        >
          {{ isCreating ? 'Creating…' : 'Confirm' }}
        </button>
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
const checkedNames = ref(new Set(
  (ext.value.alignment ?? [])
    .filter((r) => r.match === 'none')
    .map((r) => r.col_name)
))

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
  return row.match === 'exact' ? 'col-confirm-modal__row--exact' : ''
}

const confirmBtn   = ref(null)
const isCreating   = ref(false)
const errorMessage = ref(null)

onMounted(() => {
  nextTick(() => confirmBtn.value?.focus())
})

async function doCreate() {
  if (isCreating.value) return
  isCreating.value  = true
  errorMessage.value = null

  // Build distal→proximal rows for the server.
  // Exact-match ancestors pass their taxonworks_id so the server uses them as parent anchors.
  // Unchecked none-match ancestors are excluded.
  const ancestorRows = (ext.value.alignment ?? [])
    .slice()
    .reverse()  // distal first
    .filter((r) =>
      r.match === 'exact' || checkedNames.value.has(r.col_name)
    )
    .map((r) => ({
      col_name:       r.col_name,
      col_rank:       r.rank,
      col_id:         r.col_id ?? null,
      taxonworks_id:  r.match === 'exact' ? r.taxonworks_id : null,
      col_authorship: r.col_authorship ?? null,
      col_year:       null
    }))

  const targetRow = {
    col_name:       ext.value.col_name,
    col_rank:       ext.value.col_rank,
    col_id:         ext.value.col_key,
    taxonworks_id:  null,
    col_authorship: ext.value.col_authorship ?? null,
    col_year:       ext.value.col_year ?? null
  }

  try {
    const { body } = await AjaxCall('post', '/taxon_names/autoselect_col_create', {
      rows: [...ancestorRows, targetRow]
    })
    emit('confirm', body.taxon_name_id)
  } catch (err) {
    errorMessage.value = 'Creation failed. Please check the TaxonNames and try again.'
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

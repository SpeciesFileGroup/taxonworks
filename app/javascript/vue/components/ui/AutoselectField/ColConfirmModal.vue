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
          <!-- Ancestor rows: distal first -->
          <tr
            v-for="(row, index) in ancestorRowsDistalFirst"
            :key="rowKey(row, index)"
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
                v-else-if="row.match === 'conflict'"
                type="checkbox"
                disabled
              />
              <!-- A rank TaxonWorks has no equivalent for can't be created -->
              <input
                v-else-if="row.match === 'none' && row.rank_unknown"
                type="checkbox"
                disabled
                title="Not a TaxonWorks rank - can't be created"
              />
              <input
                v-else-if="row.match === 'none'"
                type="checkbox"
                :checked="checkedRowKeys.has(rowKey(row, index))"
                @change="toggleRow(rowKey(row, index))"
              />
              <!-- 'extra' rows (TaxonWorks-only ancestors) get no checkbox — always
                   sent to the server as parent anchors, never user-toggleable -->
            </td>
            <td>{{ row.rank }}</td>
            <td>{{ row.col_name ?? '—' }}</td>
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

      <p
        v-if="ext.hook?.existing_id && ext.hook.existing_named"
        class="col-confirm-modal__note"
      >
        Will use OTU <strong>{{ ext.hook.otu_label }}</strong>.
      </p>

      <p
        v-else-if="ext.hook?.existing_id && ext.hook.otu_count > 1"
        class="col-confirm-modal__note"
      >
        Will use the OTU with no name of its own,
        <strong>{{ ext.hook.otu_label }}</strong>.
        <span class="col-confirm-modal__note--warning">
          There {{ otherOtuCount === 1 ? 'is' : 'are' }}
          <a
            :href="otuFilterUrl"
            target="_blank"
            rel="noopener noreferrer"
            >{{ otherOtuCount }} other OTU{{ otherOtuCount === 1 ? '' : 's' }}</a
          >
          on this name.
        </span>
      </p>

      <p
        class="col-confirm-modal__note"
        :class="{
          'col-confirm-modal__note--warning':
            otuBlocked ||
            chainConflict ||
            isAmbiguous ||
            duplicateBlocked ||
            nonAcceptedBlocked
        }"
      >
        <template v-if="otuBlocked">
          This name has
          <a
            :href="otuFilterUrl"
            target="_blank"
            rel="noopener noreferrer"
            >{{ ext.hook.otu_count }} OTUs</a
          >
          — select the one you want directly.
        </template>
        <template v-else-if="isAmbiguous">
          {{ ext.ambiguous_match.count }} TaxonWorks records are named
          <em>{{ ext.ambiguous_match.col_name }}</em> at rank <em>{{ ext.ambiguous_match.rank }}</em> —
          there's no way to tell which one this lineage should use. Resolve this manually before creating.
        </template>
        <template v-else-if="duplicateBlocked">
          TaxonWorks already has this name as
          <span
            v-for="(duplicate, i) in ext.possible_duplicates"
            :key="duplicate.id"
            ><template v-if="i > 0">; </template
            ><a
              :href="browseTaxonNameUrl(duplicate.id)"
              target="_blank"
              rel="noopener noreferrer"
              >{{ duplicate.cached }}</a
            >
            ({{ duplicateNote(duplicate) }})</span
          >
          — select it directly instead of creating a duplicate.
        </template>
        <template v-else-if="nonAcceptedBlocked">
          Catalogue of Life status: <em>{{ ext.col_status }}</em
          ><template v-if="ext.accepted">
            of <em>{{ ext.accepted.col_name }}</em>
            {{ ext.accepted.col_authorship }}</template
          >. Catalogue of Life gives the name no classification of its own, so
          it can't be created from here. Search with a different level instead.
        </template>
        <template v-else-if="chainConflict">
          TaxonWorks and Catalogue of Life disagree at
          <template v-for="(row, i) in conflictRows" :key="row.rank">
            <template v-if="i > 0">, </template>
            <em>{{ row.rank }}</em> (TaxonWorks: {{ row.taxonworks_name }} · CoL: {{ row.col_name }})
          </template>
          — resolve this before creating.
        </template>
        <template v-else-if="nothingToCreate">
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
          :color="nothingToCreate ? 'primary' : 'create'"
          :disabled="
            isCreating ||
            cannotCreate ||
            chainConflict ||
            otuBlocked ||
            duplicateBlocked ||
            nonAcceptedBlocked
          "
          @click="doConfirm"
          @keydown.enter.prevent="doConfirm"
        >
          {{ confirmLabel }}
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
import { RouteNames } from '@/routes/routes'
import qs from 'qs'

const props = defineProps({
  item: { type: Object, required: true }
})

const emit = defineEmits(['confirm', 'cancel'])

// Shorthand for the extension hash
const ext = computed(() => props.item.extension)

// A hook result whose TaxonName has OTUs, none of which it can yield without
// the user choosing (several named ones, or several unnamed): neither Select
// nor Create - the user picks the OTU directly. The server refuses it too
// (see Autoselect::Otu::ColExistingOtu).
const otuBlocked = computed(
  () => ext.value.hook?.otu_count > 0 && !ext.value.hook.existing_id
)

// The named OTUs beside the unnamed one a hook result yields.
const otherOtuCount = computed(() => (ext.value.hook?.otu_count ?? 1) - 1)

// The OTU filter, listing every OTU on a hook result's TaxonName.
const otuFilterUrl = computed(
  () =>
    `${RouteNames.FilterOtus}?${qs.stringify(
      { taxon_name_id: [ext.value.hook?.taxon_name_id] },
      { arrayFormat: 'brackets' }
    )}`
)

// Ancestor rows in distal→proximal (kingdom-first) order — already how alignment
// comes back from Vendor::Colrapi.classified_usage.
const ancestorRowsDistalFirst = computed(() => ext.value.alignment ?? [])

// Identifies an alignment row by CoL's id, not col_name, which TaxonWorks-only
// ('extra') rows don't have. Those 'extra' rows also have no col_id, so they
// fall back to their position in the (fixed) alignment.
function rowKey(row, index) {
  return row.col_id ?? `${row.rank}:${index}`
}

// Set of rowKey values the user has checked for creation (match==='none' rows).
// Ranks above GenusGroup (family-group and higher) default to unchecked; ranks
// TaxonWorks doesn't recognize are never checked.
const checkedRowKeys = ref(
  new Set(
    (ext.value.alignment ?? [])
      .map((r, i) => [r, rowKey(r, i)])
      .filter(
        ([r]) => r.match === 'none' && !r.above_genus_group && !r.rank_unknown
      )
      .map(([, key]) => key)
  )
)

// The existing record selecting this result yields without creating anything: for
// a hook result (e.g. the OTU levels) the hook's existing record, otherwise the
// matched target TaxonName. id is null when there's none.
const existingRecord = computed(() =>
  ext.value.hook
    ? {
        id: ext.value.hook.existing_id ?? null,
        global_id: ext.value.hook.existing_global_id ?? null
      }
    : {
        id: ext.value.target_taxonworks_id ?? null,
        global_id: ext.value.target_global_id ?? null
      }
)

// True when nothing needs to be created: the record this result yields already
// exists and no ancestor rows are checked for creation.
const nothingToCreate = computed(
  () => checkedRowKeys.value.size === 0 && !!existingRecord.value.id
)

// 'Create & select' when checked ancestors are created and the record this
// result yields already exists, so both happen.
const confirmLabel = computed(() => {
  if (nothingToCreate.value) return 'Select'
  if (isCreating.value) return 'Creating…'
  return existingRecord.value.id ? 'Create & select' : 'Create'
})

// True when the target would have to be created but its rank isn't a TaxonWorks
// rank — checked ancestors don't help, the target itself can't be made
// (ColCreator refuses it too).
const cannotCreate = computed(
  () => !!ext.value.target_rank_unknown && !ext.value.target_taxonworks_id
)

// Server-computed (Autoselect::TaxonName::Levels::CatalogueOfLife#call, via
// Autoselect::TaxonName::ColAncestryComparator): whether TaxonWorks' real ancestor
// chain for the matched anchor actually agrees with CoL's classification, rank by
// rank — not just independent per-row name matches. Undefined (older/other extension
// shapes) is treated as consistent.
const chainConsistent = computed(() => ext.value.chain_consistent !== false)

// Rows where TaxonWorks' real ancestor and CoL disagree on the name at the same rank.
const conflictRows = computed(() => (ext.value.alignment ?? []).filter((r) => r.match === 'conflict'))

// Set instead of a real conflict when the walk found more than one same-name,
// same-rank TaxonWorks candidate at some position — a homonym with no principled
// way to pick between them, distinct from a genuine name disagreement.
const isAmbiguous = computed(() => !!ext.value.ambiguous_match)

// Only blocks Create itself — nothingToCreate's "Select" shortcut doesn't create or
// reparent anything, so a pre-existing inconsistency among already-matched records
// isn't this action's problem to block.
const chainConflict = computed(() => !chainConsistent.value && !nothingToCreate.value)

// Server-computed (Autoselect::TaxonName::ColMatch#possible_duplicates):
// TaxonWorks names CoL's target is the published form of (an original
// combination, or a Combination) - the taxon is already in TaxonWorks, placed
// differently, so creating it would duplicate it.
const duplicateBlocked = computed(
  () =>
    (ext.value.possible_duplicates ?? []).length > 0 && !nothingToCreate.value
)

// Server-computed (Vendor::Colrapi.classified_usage): CoL doesn't accept the
// target (synonym, misapplied, ...) and has no classification of its own for
// it, so it can't be created (ColCreator refuses it too). Selecting it when
// TaxonWorks already has the name is fine.
const nonAcceptedBlocked = computed(
  () => !!ext.value.non_accepted && !ext.value.target_taxonworks_id
)

// e.g. "originally Deltocephalus pumilicans, valid name Vilargus pumilicans"
function duplicateNote(duplicate) {
  const how =
    duplicate.via === 'combination'
      ? 'a Combination'
      : `originally ${duplicate.published}`
  return duplicate.valid_cached
    ? `${how}, valid name ${duplicate.valid_cached}`
    : how
}

function browseTaxonNameUrl(id) {
  return `${RouteNames.BrowseNomenclature}?taxon_name_id=${id}`
}

// Returns a Checklistbank web URL including dataset context, falling back to
// the legacy catalogueoflife.org path when no dataset_id is available.
function clbTaxonUrl(datasetId, taxonId) {
  if (datasetId) {
    return `https://www.checklistbank.org/dataset/${datasetId}/taxon/${taxonId}`
  }
  return `https://www.catalogueoflife.org/data/taxon/${taxonId}`
}

function toggleRow(key) {
  if (checkedRowKeys.value.has(key)) {
    checkedRowKeys.value.delete(key)
  } else {
    checkedRowKeys.value.add(key)
  }
  // Force reactivity on Set mutation
  checkedRowKeys.value = new Set(checkedRowKeys.value)
}

function rowClass(row) {
  if (errorColId.value !== null && row.col_id === errorColId.value) return 'col-confirm-modal__row--error'
  if (row.match === 'exact') return 'col-confirm-modal__row--exact'
  if (row.match === 'extra') return 'col-confirm-modal__row--extra'
  if (row.match === 'conflict') return 'col-confirm-modal__row--conflict'
  return ''
}

const confirmBtn = ref(null)
const isCreating = ref(false)
const errorColId = ref(null)

onMounted(() => {
  nextTick(() => confirmBtn.value?.$el?.focus())
})

function doConfirm() {
  if (nothingToCreate.value) {
    emit('confirm', { ...existingRecord.value })
    return
  }
  doCreate()
}

async function doCreate() {
  if (isCreating.value) return
  isCreating.value = true
  errorColId.value = null

  // Build distal→proximal rows for the server — alignment already comes back in that
  // order (kingdom-first) from Vendor::Colrapi.classified_usage.
  // 'exact', 'extra' and 'conflict' ancestors all pass their taxonworks_id (for a
  // 'conflict' row that's TaxonWorks' own record at that rank): the server walks them
  // as parent anchors so the chain it sees is a faithful, contiguous picture of the
  // real TaxonWorks lineage. Dropping any of them here would leave a gap: the
  // server would see an existing record under the wrong row above it with nothing
  // inserted between, and refuse the request (ColCreator only reparents onto a row
  // it just created).
  // Unchecked 'none' rows are the only alignment rows left out.
  const ancestorRows = (ext.value.alignment ?? [])
    .filter(
      (r, i) =>
        r.match === 'exact' ||
        r.match === 'extra' ||
        r.match === 'conflict' ||
        checkedRowKeys.value.has(rowKey(r, i))
    )
    .map((r) => ({
      col_name: r.col_name,
      col_rank: r.rank,
      col_id: r.col_id ?? null,
      dataset_id: r.dataset_id ?? null,
      taxonworks_id: r.match === 'none' ? null : r.taxonworks_id,
      col_authorship: r.col_authorship ?? null,
      col_year: null
    }))

  const targetRow = {
    col_name: ext.value.col_name,
    col_rank: ext.value.col_rank,
    col_id: ext.value.col_key,
    dataset_id: ext.value.col_dataset_id ?? null,
    // When the target itself already exists locally (ext.target_taxonworks_id, set by
    // TaxonName::Levels::CatalogueOfLife#call), pass it through so ColCreator reuses it
    // instead of creating a duplicate — same as exact-match ancestor rows above. A hook
    // flow (e.g. OTU creation) reaches here with an existing target when its own record
    // doesn't exist yet, or when ancestor rows are checked; the create endpoint then
    // makes (or reuses) its own record.
    taxonworks_id: ext.value.target_taxonworks_id ?? null,
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
    errorColId.value = err.response?.body?.failed_col_id ?? null
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
  border: 1px solid var(--border-color);
  padding: 2px 5px;
  text-align: left;
  vertical-align: middle;
}

.col-confirm-modal__table th {
  background: var(--input-bg-color);
  font-weight: 600;
}

.col-confirm-modal__row--exact {
  background-color: rgba(0, 128, 0, 0.06);
}

/* An ancestor that exists in TaxonWorks at a rank where CoL's chain has
   nothing - shown for context only, nothing to select or create. */
.col-confirm-modal__row--extra {
  background-color: rgba(0, 90, 200, 0.06);
}

.col-confirm-modal__row--conflict {
  background-color: rgba(200, 0, 0, 0.08);
}

.col-confirm-modal__row--target {
  font-weight: 600;
  border-top: 2px solid var(--border-color);
}

.col-confirm-modal__row--error {
  background-color: rgba(200, 0, 0, 0.08);
}

.col-confirm-modal__note {
  font-size: 11px;
  color: var(--text-muted-color);
  margin: 4px 0 0;
}

.col-confirm-modal__note--warning {
  color: var(--color-destroy);
}

.col-confirm-modal__error {
  color: var(--color-destroy);
  font-size: 12px;
  margin-top: 6px;
}

.col-confirm-modal__footer {
  display: flex;
  align-items: center;
  gap: 8px;
}
</style>

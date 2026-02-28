<!-- OtuNewModal.vue
  Modal triggered by the !n operator in AutoselectField when searching OTUs.
  Presents a mini create-OTU form: a Name text input and a TaxonName autocomplete.

  Secondary TaxonName search:
  - On open, searches /taxon_names/autocomplete?term=<namePrefill>&exact=true
  - If exactly 1 result  → pre-populates the TaxonName autocomplete field
  - If more than 1 result → shows a radio-button disambiguation list; selecting one collapses
    the list and assigns that TaxonName

  Tab order: Name → TaxonName autocomplete → Create → back-arrow

  Emits:
    confirm({ otuName, taxonNameId, taxonNameLabel })  — user clicked Create
    cancel                                              — user backed out
-->
<template>
  <Modal
    :container-style="{ maxWidth: '480px', width: '90vw' }"
    @close="emit('cancel')"
  >
    <template #header>
      <span>Create new OTU</span>
    </template>

    <template #body>
      <div class="otu-new-modal__form">
        <!-- Name -->
        <label class="otu-new-modal__label" for="otu-new-name">Name</label>
        <input
          id="otu-new-name"
          ref="nameInputEl"
          v-model="otuName"
          type="text"
          class="otu-new-modal__input normal-input"
          placeholder="OTU name (optional)"
          autocomplete="off"
          tabindex="1"
          @keydown.enter.prevent="focusTaxonNameInput"
        />

        <!-- TaxonName autocomplete -->
        <label class="otu-new-modal__label" for="otu-new-taxon-name">Taxon name</label>

        <div class="otu-new-modal__taxon-row">
          <!-- Show selected TaxonName badge or the autocomplete input -->
          <template v-if="selectedTaxonName">
            <span class="otu-new-modal__taxon-selected">
              <span v-html="selectedTaxonName.label_html || selectedTaxonName.label" />
              <button
                class="otu-new-modal__taxon-clear"
                title="Clear taxon name"
                tabindex="3"
                @click="clearTaxonName"
              >&#x2715;</button>
            </span>
          </template>
          <template v-else>
            <Autocomplete
              ref="taxonNameAutocompleteEl"
              url="/taxon_names/autocomplete"
              param="term"
              label="label_html"
              placeholder="Search a taxon name..."
              input-id="otu-new-taxon-name"
              :input-tab-index="2"
              clear-after
              @get-item="onTaxonNameSelected"
            />
          </template>

          <!-- Disambiguation spinner -->
          <span v-if="isSearchingTaxonNames" class="otu-new-modal__searching">…</span>
        </div>

        <!-- Disambiguation list (>1 TaxonName match) -->
        <ul
          v-if="disambiguationList.length > 0 && !selectedTaxonName"
          class="otu-new-modal__disambig"
        >
          <li
            v-for="item in disambiguationList"
            :key="item.id"
            class="otu-new-modal__disambig-item"
          >
            <label>
              <input
                type="radio"
                name="taxon-name-disambig"
                :value="item.id"
                @change="onDisambigSelect(item)"
              />
              <span v-html="item.label_html || item.label" />
              <span v-if="item.object_tag" class="otu-new-modal__disambig-info">{{ item.object_tag }}</span>
            </label>
          </li>
        </ul>

        <p v-if="errorMessage" class="otu-new-modal__error">{{ errorMessage }}</p>
      </div>
    </template>

    <template #footer>
      <div class="otu-new-modal__footer">
        <button
          ref="createBtn"
          class="button button-submit"
          :disabled="isCreating || !otuName.trim()"
          tabindex="3"
          @click="doCreate"
          @keydown.enter.prevent="doCreate"
        >
          {{ isCreating ? 'Creating…' : 'Create' }}
        </button>
        <button
          class="button circle-button btn-undo button-default"
          :disabled="isCreating"
          title="Cancel — return to search"
          tabindex="4"
          @click="emit('cancel')"
        >
          &#8617;
        </button>
      </div>
    </template>
  </Modal>
</template>

<script setup>
// # Claude: provided >50% of this component
import { ref, onMounted, nextTick } from 'vue'
import Modal from '@/components/ui/Modal.vue'
import Autocomplete from '@/components/ui/Autocomplete.vue'
import AjaxCall from '@/helpers/ajaxCall'

const props = defineProps({
  // The pre-filled name value (from the term with !n stripped)
  namePrefill: { type: String, default: '' }
})

const emit = defineEmits(['confirm', 'cancel'])

// ── Refs ───────────────────────────────────────────────────────────────────────
const nameInputEl = ref(null)
const taxonNameAutocompleteEl = ref(null)
const createBtn = ref(null)

const otuName = ref(props.namePrefill)
const selectedTaxonName = ref(null)
const disambiguationList = ref([])
const isSearchingTaxonNames = ref(false)
const isCreating = ref(false)
const errorMessage = ref(null)

// ── Lifecycle ──────────────────────────────────────────────────────────────────
onMounted(() => {
  nextTick(() => {
    nameInputEl.value?.focus()
    nameInputEl.value?.select()

    if (props.namePrefill.trim()) {
      searchTaxonNamesByExactName(props.namePrefill.trim())
    }
  })
})

// ── TaxonName secondary search ─────────────────────────────────────────────────
async function searchTaxonNamesByExactName(name) {
  isSearchingTaxonNames.value = true
  disambiguationList.value = []

  try {
    const { body } = await AjaxCall('get', '/taxon_names/autocomplete', {
      params: { term: name, exact: 'true' }
    })

    const results = Array.isArray(body) ? body : []

    if (results.length === 1) {
      // Single exact match — pre-populate silently
      selectedTaxonName.value = results[0]
    } else if (results.length > 1) {
      // Multiple matches — show radio disambiguation
      disambiguationList.value = results
    }
    // 0 matches — leave the autocomplete empty
  } catch (_err) {
    // Non-critical; leave TaxonName blank
  } finally {
    isSearchingTaxonNames.value = false
  }
}

// ── Event handlers ─────────────────────────────────────────────────────────────
function onTaxonNameSelected(item) {
  selectedTaxonName.value = item
  disambiguationList.value = []
  // After selecting, move focus to Create
  nextTick(() => createBtn.value?.focus())
}

function onDisambigSelect(item) {
  selectedTaxonName.value = item
  disambiguationList.value = []
  nextTick(() => createBtn.value?.focus())
}

function clearTaxonName() {
  selectedTaxonName.value = null
  disambiguationList.value = []
  nextTick(() => taxonNameAutocompleteEl.value?.$el?.querySelector('input')?.focus())
}

function focusTaxonNameInput() {
  nextTick(() =>
    taxonNameAutocompleteEl.value?.$el?.querySelector('input')?.focus()
  )
}

// ── Create ─────────────────────────────────────────────────────────────────────
async function doCreate() {
  if (isCreating.value || !otuName.value.trim()) return

  isCreating.value = true
  errorMessage.value = null

  try {
    const payload = { otu: { name: otuName.value.trim() } }
    if (selectedTaxonName.value?.id) {
      payload.otu.taxon_name_id = selectedTaxonName.value.id
    }

    const { body } = await AjaxCall('post', '/otus', payload)

    if (body?.id) {
      emit('confirm', {
        otuId: body.id,
        otuName: body.name || otuName.value.trim(),
        taxonNameId: selectedTaxonName.value?.id ?? null,
        taxonNameLabel: selectedTaxonName.value?.label ?? null
      })
    } else {
      errorMessage.value = 'Creation failed. Please try again.'
    }
  } catch (_err) {
    errorMessage.value = 'Creation failed. Please try again.'
  } finally {
    isCreating.value = false
  }
}
</script>

<style scoped>
.otu-new-modal__form {
  display: flex;
  flex-direction: column;
  gap: 6px;
  font-size: 12px;
}

.otu-new-modal__label {
  font-weight: 600;
  font-size: 11px;
  color: var(--text-color-muted, #666);
  margin-bottom: 1px;
}

.otu-new-modal__input {
  width: 100%;
  box-sizing: border-box;
}

.otu-new-modal__taxon-row {
  display: flex;
  align-items: center;
  gap: 6px;
  width: 100%;
}

.otu-new-modal__taxon-row :deep(.vue-autocomplete) {
  flex: 1;
  min-width: 0;
}

.otu-new-modal__taxon-selected {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 3px 8px;
  background: var(--input-bg-color, #f9f9f9);
  border: 1px solid var(--border-color, #ccc);
  border-radius: 3px;
  font-size: 12px;
  flex: 1;
  min-width: 0;
}

.otu-new-modal__taxon-clear {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 11px;
  color: var(--text-color-muted, #888);
  padding: 0 2px;
  line-height: 1;
}

.otu-new-modal__taxon-clear:hover {
  color: var(--color-destroy, #c00);
}

.otu-new-modal__searching {
  font-size: 11px;
  color: var(--text-color-muted, #888);
  white-space: nowrap;
}

.otu-new-modal__disambig {
  list-style: none;
  margin: 0;
  padding: 0;
  border: 1px solid var(--border-color, #ccc);
  border-radius: 3px;
  max-height: 160px;
  overflow-y: auto;
  background: var(--panel-bg-color, #fff);
}

.otu-new-modal__disambig-item {
  border-top: 1px solid var(--border-color, #ccc);
  padding: 4px 8px;
}

.otu-new-modal__disambig-item:first-child {
  border-top: none;
}

.otu-new-modal__disambig-item label {
  display: flex;
  align-items: baseline;
  gap: 6px;
  cursor: pointer;
  font-size: 12px;
}

.otu-new-modal__disambig-info {
  font-size: 10px;
  opacity: 0.7;
  white-space: nowrap;
}

.otu-new-modal__error {
  color: var(--color-destroy, #c00);
  font-size: 12px;
  margin: 4px 0 0;
}

.otu-new-modal__footer {
  display: flex;
  align-items: center;
  gap: 8px;
}

.otu-new-modal__footer .button-submit {
  padding-left: 20px;
  padding-right: 20px;
}
</style>

<!-- TaxonNameNewModal.vue
  # Claude: provided >50% of this component
  Modal triggered by the !n operator in AutoselectField when searching TaxonNames.
  Presents a mini create-Protonym form: Name, Parent autocomplete, and Rank selector.

  On open, focuses the Name input. namePrefill pre-fills the Name field.
  When a parent is selected, calls /taxon_names/predicted_rank to auto-suggest rank.

  Emits:
    confirm({ id, label, label_html, info, response_values, extension })  — user clicked Create
    cancel  — user backed out
-->
<template>
  <Modal
    :container-style="{ maxWidth: '480px', width: '90vw' }"
    @close="emit('cancel')"
  >
    <template #header>
      <span>Create new taxon name</span>
    </template>

    <template #body>
      <div class="tn-new-modal__form">
        <!-- Name -->
        <label class="tn-new-modal__label" for="tn-new-name">Name</label>
        <input
          id="tn-new-name"
          ref="nameInputEl"
          v-model="name"
          type="text"
          class="tn-new-modal__input normal-input"
          placeholder="Uninomial or epithet"
          autocomplete="off"
          tabindex="1"
          @keydown.tab.exact.prevent="focusParentInput"
        />

        <!-- Parent -->
        <label class="tn-new-modal__label" for="tn-new-parent">Parent</label>
        <div class="tn-new-modal__row">
          <template v-if="selectedParent">
            <span class="tn-new-modal__selected">
              <span v-html="selectedParent.label_html || selectedParent.label" />
              <button
                class="tn-new-modal__clear"
                title="Clear parent"
                tabindex="3"
                @click="clearParent"
              >&#x2715;</button>
            </span>
          </template>
          <template v-else>
            <Autocomplete
              ref="parentAutocompleteEl"
              url="/taxon_names/autocomplete"
              param="term"
              label="label_html"
              placeholder="Search parent taxon name…"
              input-id="tn-new-parent"
              :input-tab-index="2"
              clear-after
              @get-item="onParentSelected"
            />
          </template>
          <span v-if="isPredictingRank" class="tn-new-modal__searching">…</span>
        </div>

        <!-- Rank -->
        <label class="tn-new-modal__label" for="tn-new-rank">Rank</label>
        <select
          id="tn-new-rank"
          v-model="rankClass"
          class="tn-new-modal__select normal-input"
          tabindex="3"
        >
          <option value="">-- Select rank --</option>
          <template
            v-for="(codeGroups, code) in ranksData"
            :key="code"
          >
            <optgroup :label="code.toUpperCase()">
              <template
                v-for="(rankList, group) in codeGroups"
                :key="group"
              >
                <option
                  v-for="rank in rankList"
                  :key="rank.rank_class"
                  :value="rank.rank_class"
                >
                  {{ rank.name }}
                </option>
              </template>
            </optgroup>
          </template>
        </select>

        <p v-if="errorMessage" class="tn-new-modal__error">{{ errorMessage }}</p>
      </div>
    </template>

    <template #footer>
      <div class="tn-new-modal__footer">
        <VBtn
          ref="createBtn"
          color="create"
          :disabled="isCreating || !canCreate"
          tabindex="4"
          @click="doCreate"
          @keydown.enter.prevent="doCreate"
        >
          {{ isCreating ? 'Creating…' : 'Create' }}
        </VBtn>
        <button
          class="button circle-button btn-undo button-default"
          :disabled="isCreating"
          title="Cancel — return to search"
          tabindex="5"
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
import Autocomplete from '@/components/ui/Autocomplete.vue'
import { TaxonName } from '@/routes/endpoints'

const props = defineProps({
  namePrefill: { type: String, default: '' }
})

const emit = defineEmits(['confirm', 'cancel'])

// ── Refs ───────────────────────────────────────────────────────────────────────
const nameInputEl = ref(null)
const parentAutocompleteEl = ref(null)
const createBtn = ref(null)

const name = ref(props.namePrefill)
const selectedParent = ref(null)
const rankClass = ref('')
const ranksData = ref({})
const isPredictingRank = ref(false)
const isCreating = ref(false)
const errorMessage = ref(null)

// ── Computed ───────────────────────────────────────────────────────────────────
const canCreate = computed(
  () => name.value.trim().length > 0 && rankClass.value && selectedParent.value
)

// Human-readable rank name for the info field on selection item
const rankDisplayName = computed(() => {
  if (!rankClass.value) return null
  for (const [code, groups] of Object.entries(ranksData.value)) {
    for (const rankList of Object.values(groups)) {
      const found = rankList.find((r) => r.rank_class === rankClass.value)
      if (found) return `${found.name} (${code})`
    }
  }
  return null
})

// ── Lifecycle ──────────────────────────────────────────────────────────────────
onMounted(async () => {
  nextTick(() => {
    nameInputEl.value?.focus()
    nameInputEl.value?.select()
  })
  try {
    const { body } = await TaxonName.ranks()
    ranksData.value = body || {}
  } catch (_err) {
    // Rank list unavailable — user can still type a rank_class manually
  }
})

// ── Parent selection ───────────────────────────────────────────────────────────
async function onParentSelected(item) {
  selectedParent.value = item
  await predictRankForParent(item.id)
  nextTick(() => {
    if (!rankClass.value) {
      document.getElementById('tn-new-rank')?.focus()
    } else {
      createBtn.value?.$el?.focus()
    }
  })
}

function clearParent() {
  selectedParent.value = null
  rankClass.value = ''
  nextTick(() =>
    parentAutocompleteEl.value?.$el?.querySelector('input')?.focus()
  )
}

async function predictRankForParent(parentId) {
  isPredictingRank.value = true
  try {
    const { body } = await TaxonName.predictedRank(parentId, name.value)
    if (body?.predicted_rank) {
      rankClass.value = body.predicted_rank
    }
  } catch (_err) {
    // Prediction failed — leave rank blank for user to choose
  } finally {
    isPredictingRank.value = false
  }
}

// ── Focus helpers ──────────────────────────────────────────────────────────────
function focusParentInput() {
  nextTick(() =>
    parentAutocompleteEl.value?.$el?.querySelector('input')?.focus()
  )
}

// ── Create ─────────────────────────────────────────────────────────────────────
async function doCreate() {
  if (isCreating.value || !canCreate.value) return

  isCreating.value = true
  errorMessage.value = null

  try {
    const { body } = await TaxonName.create({
      taxon_name: {
        type: 'Protonym',
        name: name.value.trim(),
        rank_class: rankClass.value,
        parent_id: selectedParent.value.id
      }
    })

    if (body?.id) {
      const label = body.cached || name.value.trim()
      emit('confirm', {
        id: body.id,
        label,
        label_html: label,
        info: rankDisplayName.value,
        response_values: { taxon_name_id: body.id },
        extension: {}
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
.tn-new-modal__form {
  display: flex;
  flex-direction: column;
  gap: 6px;
  font-size: 12px;
}

.tn-new-modal__label {
  font-weight: 600;
  font-size: 11px;
  color: var(--text-color-muted, #666);
  margin-bottom: 1px;
}

.tn-new-modal__input,
.tn-new-modal__select {
  width: 100%;
  box-sizing: border-box;
}

.tn-new-modal__row {
  display: flex;
  align-items: center;
  gap: 6px;
  width: 100%;
}

.tn-new-modal__row :deep(.vue-autocomplete) {
  flex: 1;
  min-width: 0;
}

.tn-new-modal__selected {
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

.tn-new-modal__clear {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 11px;
  color: var(--text-color-muted, #888);
  padding: 0 2px;
  line-height: 1;
}

.tn-new-modal__clear:hover {
  color: var(--color-destroy, #c00);
}

.tn-new-modal__searching {
  font-size: 11px;
  color: var(--text-color-muted, #888);
  white-space: nowrap;
}

.tn-new-modal__error {
  color: var(--color-destroy, #c00);
  font-size: 12px;
  margin: 4px 0 0;
}

.tn-new-modal__footer {
  display: flex;
  align-items: center;
  gap: 8px;
}
</style>

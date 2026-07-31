<template>
  <VSpinner
    v-if="loading"
    full-screen
  />

  <h1>{{ currentStep === 1 ? (isAddMode ? 'Edit cited key' : 'Cite a key') : 'Annotate cited key' }}</h1>

  <NavBar navbar-class="panel content cite-key-navbar">
    <div class="flex-separate middle">
      <ol class="step-nav no-style-list d-flex gap-medium middle">
        <li
          v-for="step in STEPS"
          :key="step.n"
          :class="['step-item d-flex middle gap-small',
            { 'step-active': currentStep === step.n, 'step-done': currentStep > step.n }]"
          :aria-current="currentStep === step.n ? 'step' : undefined"
        >
          <span
            class="step-number d-flex middle justify-center"
            @click="goToStep(step.n)"
          >{{ step.n }}</span>
          <span
            class="step-label"
            @click="goToStep(step.n)"
          >{{ step.label }}</span>
        </li>
      </ol>
      <div class="d-flex middle gap-small">
        <VBtn
          v-if="currentStep === 1 && (!isAddMode || canSave)"
          color="create"
          :disabled="!canSave"
          @click="save"
        >
          {{ saveButtonText }}
        </VBtn>
        <VBtn
          v-if="rootId"
          color="primary"
          @click="reset"
        >
          Cite a new key
        </VBtn>
      </div>
    </div>
  </NavBar>

  <!-- Step 1: Create key + species list -->
  <template v-if="!bootLoading && currentStep === 1">
    <BlockLayout
      expand
      class="margin-medium-bottom"
    >
      <template #header>
        <h3>Citation</h3>
      </template>

      <template #body>
        <div class="field label-above">
          <label>Source</label>
          <div
            v-if="source"
            class="d-flex middle gap-small"
          >
            <span
              v-html="source.label_html || source.object_tag"
              class="margin-small-right"
            />
            <span
              class="button button-circle btn-undo button-default"
              title="Clear source"
              @click="clearSource"
            />
          </div>
          <div
            v-else
            class="horizontal-left-content gap-small"
          >
            <Autocomplete
              class="full_width"
              url="/sources/autocomplete"
              placeholder="Search for a source (citation)"
              param="term"
              min="2"
              clear-after
              label="label_html"
              @get-item="selectSource"
            />
            <ButtonPinned
              type="Source"
              section="Sources"
              @get-id="selectSourceById"
            />
          </div>
        </div>

        <div
          v-if="source"
          class="field label-above"
        >
          <label>Page range</label>
          <input
            type="text"
            class="full_width"
            v-model="pages"
            placeholder="Optional; can also be edited per taxon in Step 2"
          />
        </div>

        <div
          v-if="source"
          class="separate-top margin-medium-top"
        >
          <label class="font-bold">Existing cited keys for this source</label>
          <div
            v-if="existingKeysLoading"
            class="small_type padding-xsmall"
          >
            Checking for existing keys…
          </div>
          <div
            v-else-if="existingKeys.length"
            class="taxa-grid margin-small-top"
            role="table"
            aria-label="Existing cited keys for this source"
            :style="{ gridTemplateColumns: 'max-content max-content max-content max-content max-content 1fr' }"
          >
            <div
              class="taxa-grid-row taxa-grid-header"
              role="row"
            >
              <div role="columnheader">Title</div>
              <div role="columnheader">Root taxon</div>
              <div role="columnheader">Pages</div>
              <div role="columnheader">Taxa</div>
              <div role="columnheader" />
              <div
                role="columnheader"
                aria-hidden="true"
                class="taxa-grid-spacer"
              />
            </div>
            <div
              v-for="key in existingKeys"
              :key="key.id"
              class="taxa-grid-row"
              role="row"
            >
              <div role="cell">{{ key.text }}</div>
              <div
                role="cell"
                v-html="key.rootTaxonTag ?? '—'"
              />
              <div role="cell">{{ key.pages || '—' }}</div>
              <div role="cell">{{ key.count }}</div>
              <div role="cell">
                <VBtn
                  color="primary"
                  @click="loadKey(key.id)"
                >
                  Open
                </VBtn>
              </div>
              <div
                role="cell"
                aria-hidden="true"
                class="taxa-grid-spacer"
              />
            </div>
          </div>
          <div
            v-else
            class="small_type padding-xsmall"
          >
            No existing cited keys for this source. Fill out the fields below to record a new one.
          </div>
        </div>
      </template>
    </BlockLayout>

    <BlockLayout
      expand
      class="margin-medium-bottom"
    >
      <template #header>
        <h3>Key metadata</h3>
      </template>

      <template #body>
        <div class="field label-above">
          <label>Title</label>
          <textarea
            class="full_width"
            v-model="root.text"
            rows="2"
            placeholder="e.g. Key to Ceroplastes of Iran (Moghaddam 2013)"
          />
        </div>

        <div class="field label-above">
          <label>Parent OTU</label>
          <div
            v-if="parentOtu"
            class="d-flex middle gap-small"
          >
            <span
              v-html="parentOtu.object_tag"
              class="margin-small-right"
            />
            <span
              class="button button-circle btn-undo button-default"
              title="Clear parent OTU"
              @click="clearParent"
            />
          </div>
          <OtuPicker
            v-else
            :clear-after="true"
            @get-item="selectParent"
          />
        </div>
      </template>
    </BlockLayout>

    <BlockLayout
      expand
      class="margin-medium-bottom"
      :set-expanded="!!parentOtu || species.length > 0"
    >
      <template #header>
        <h3>Taxa in key ({{ species.length }})</h3>
      </template>

      <template #body>
        <div class="d-flex gap-small middle margin-medium-bottom flex-wrap-row">
          <label
            for="descendants_filter"
            class="margin-small-right"
          >Descendants filter</label>
          <select
            id="descendants_filter"
            v-model="descendantsFilter"
          >
            <option
              v-for="opt in DESCENDANTS_FILTERS"
              :key="opt.value"
              :value="opt.value"
            >
              {{ opt.label }}
            </option>
          </select>
          <VBtn
            color="primary"
            :disabled="!parentOtu || descendantsLoading"
            @click="loadDescendants"
          >
            {{ descendantsLoading ? 'Loading...' : 'Add descendants' }}
          </VBtn>
          <label
            class="d-flex middle gap-small margin-medium-left"
            :title="source?.cached_nomenclature_date
              ? `Skip taxa published after ${source.cached_nomenclature_date}`
              : 'Pick a source to enable pruning by publication date'"
          >
            <input
              type="checkbox"
              v-model="autoPruneAfterPublication"
              :disabled="!source?.cached_nomenclature_date"
            />
            Auto-prune taxa published after the key
          </label>
          <label
            class="d-flex middle gap-small"
            title="Skip taxa marked as misspellings (cached_misspelling or [sic] in the name)"
          >
            <input
              type="checkbox"
              v-model="pruneMisspellings"
            />
            Prune misspellings
          </label>
          <VBtn
            color="primary"
            :disabled="!newSpecies.length"
            title="Discards taxa that haven't been saved yet; already-saved taxa stay in the key"
            @click="clearPendingSpecies"
          >
            Clear pending
          </VBtn>
        </div>

        <div class="field label-above">
          <label>Add OTU</label>
          <Autocomplete
            class="full_width"
            url="/otus/autocomplete"
            placeholder="Add an OTU to this key"
            param="term"
            clear-after
            label="label_html"
            @get-item="addSpecies"
          />
        </div>

        <ul
          v-if="species.length"
          class="no-style-list panel content species-grid"
        >
          <li
            v-for="otu in sortedSpecies"
            :key="otu.id"
            :class="['d-flex middle gap-small padding-xsmall species-row',
              { 'species-row-saved': !!childLeads[otu.id] }]"
          >
            <span
              v-if="childLeads[otu.id]"
              class="button button-circle btn-delete"
              title="Delete permanently from key"
              @click="deleteChildLead(otu)"
            />
            <span
              v-else
              class="button button-circle btn-undo button-default"
              title="Remove from list"
              @click="removeSpecies(otu.id)"
            />
            <span
              class="ellipsis"
              v-html="taxonDisplay(otu)"
            />
          </li>
        </ul>
        <div
          v-else
          class="feedback feedback-info padding-small text-center"
        >
          No taxa added. Pick a parent OTU and click
          <em>Add descendants</em>, or add OTUs individually above.
        </div>
      </template>
    </BlockLayout>

  </template>

  <!-- Step 2: Annotate species -->
  <template v-else-if="!bootLoading">
    <BlockLayout
      class="margin-medium-bottom"
    >
      <template #header>
        <div class="flex-separate middle full_width">
          <h3>Key metadata</h3>
          <div class="horizontal-right-content gap-small header-radials">
            <RadialAnnotator :global-id="rootGlobalId" />
            <RadialNavigator
              :global-id="rootGlobalId"
              exclude="Edit"
            />
          </div>
        </div>
      </template>

      <template #body>
        <div class="field label-above">
          <label>Title</label>
          <div>{{ root.text }}</div>
        </div>
        <div class="field label-above">
          <label>Parent OTU</label>
          <div v-if="parentOtu" v-html="parentOtu.object_tag" />
        </div>
        <div class="field label-above">
          <label>Source (citation)</label>
          <div v-if="source" v-html="source.label_html || source.object_tag" />
        </div>
        <div
          v-if="pages"
          class="field label-above"
        >
          <label>Page range</label>
          <div>{{ pages }}</div>
        </div>
      </template>
    </BlockLayout>

    <BlockLayout
      :class="['margin-medium-bottom', { 'taxa-fullscreen': taxaFullScreen }]"
    >
      <template #header>
        <div class="flex-separate middle full_width">
          <h3>Taxa in key ({{ sortedSavedSpecies.length }})</h3>
          <span
            :data-icon="taxaFullScreen ? 'contract' : 'expand'"
            :title="taxaFullScreen ? 'Exit full-screen (Esc)' : 'Full-screen data view'"
            class="fullscreen-toggle"
            @click="taxaFullScreen = !taxaFullScreen"
          />
        </div>
      </template>

      <template #body>
        <div
          v-if="species.length"
          class="taxa-grid"
          role="table"
          aria-label="Taxa in this cited key"
          :style="{ gridTemplateColumns }"
        >
          <div
            class="taxa-grid-row taxa-grid-header"
            role="row"
          >
            <div role="columnheader" />
            <div role="columnheader">Taxon</div>
            <div role="columnheader">
              <div class="d-flex flex-col gap-small">
                <span>Page</span>
                <div class="d-flex gap-small middle">
                  <input
                    v-model="bulkPagesValue"
                    type="text"
                    class="input-small-width"
                    placeholder="Apply to all"
                  />
                  <VBtn
                    v-if="bulkPagesValue"
                    color="primary"
                    small
                    @click="applyBulkPages"
                  >
                    Apply
                  </VBtn>
                </div>
              </div>
            </div>
            <div
              v-for="col in columns"
              :key="col.cvtId"
              role="columnheader"
              class="taxa-grid-cvcol"
            >
              <div class="d-flex flex-col gap-small">
                <div class="d-flex middle gap-small">
                  <span v-html="col.cvtName" />
                  <span
                    class="button button-circle btn-undo button-default"
                    title="Remove column from view (does not delete data)"
                    @click="removeColumn(col.cvtId)"
                  />
                </div>
                <div class="d-flex middle gap-small">
                  <input
                    v-if="col.type === 'keyword'"
                    type="checkbox"
                    v-model="bulkColumnValues[col.cvtId]"
                    title="Check all rows on Apply"
                  />
                  <input
                    v-else
                    type="text"
                    class="predicate-cell-input"
                    v-model="bulkColumnValues[col.cvtId]"
                    placeholder="Apply to all"
                  />
                  <VBtn
                    v-if="col.type === 'keyword' ? bulkColumnValues[col.cvtId] : bulkColumnValues[col.cvtId]"
                    color="primary"
                    small
                    @click="applyBulkColumn(col)"
                  >
                    Apply
                  </VBtn>
                </div>
              </div>
            </div>
            <div
              role="columnheader"
              class="taxa-grid-addcol"
            >
              <div
                v-if="showAddColumn"
                class="d-flex flex-col gap-small add-column-picker"
              >
                <Autocomplete
                  class="add-column-autocomplete"
                  url="/controlled_vocabulary_terms/autocomplete"
                  :add-params="{ type: ['Keyword', 'Predicate'] }"
                  placeholder="Search vocabulary"
                  param="term"
                  min="1"
                  clear-after
                  label="label_html"
                  @get-item="pickColumnCvt"
                />
                <div
                  v-if="newColumnCvt"
                  class="small_type"
                >
                  Selected:
                  <span v-html="newColumnCvt.label_html || newColumnCvt.label" />
                </div>
                <div class="d-flex middle gap-small">
                  <VBtn
                    color="primary"
                    small
                    :disabled="!newColumnCvt"
                    @click="addColumn"
                  >
                    Add
                  </VBtn>
                  <VBtn
                    color="primary"
                    small
                    @click="cancelAddColumn"
                  >
                    Cancel
                  </VBtn>
                  <a
                    href="/tasks/controlled_vocabularies/manage"
                    target="_blank"
                    rel="noopener"
                    class="small_type margin-small-left"
                  >
                    New term
                  </a>
                </div>
              </div>
              <VBtn
                v-else
                color="primary"
                circle
                small
                title="Add a controlled vocabulary column"
                @click="openAddColumn"
              >
                +
              </VBtn>
            </div>
            <div
              role="columnheader"
              aria-hidden="true"
              class="taxa-grid-spacer"
            />
          </div>
          <div
            v-for="otu in sortedSavedSpecies"
            :key="otu.id"
            class="taxa-grid-row"
            role="row"
          >
            <div role="cell">
              <div class="d-flex middle gap-small">
                <RadialAnnotator
                  v-if="childLeads[otu.id]"
                  :global-id="childLeads[otu.id].global_id"
                />
                <span
                  v-if="childLeads[otu.id]"
                  class="button button-circle btn-delete"
                  title="Delete permanently from key"
                  @click="deleteChildLead(otu)"
                />
              </div>
            </div>
            <div role="cell">
              <span v-html="taxonDisplay(otu)" />
            </div>
            <div role="cell">
              <input
                v-if="childCitations[otu.id]"
                v-model="childCitations[otu.id].pages"
                type="text"
                class="input-small-width"
                :data-cell="`page:${otu.id}`"
                @blur="autoSavePage(otu.id)"
                @keydown.enter.prevent="autoSavePage(otu.id); focusNextRowSameColumn('page', otu.id)"
              />
            </div>
            <div
              v-for="col in columns"
              :key="col.cvtId"
              role="cell"
              class="taxa-grid-cvcol"
            >
              <input
                v-if="col.type === 'keyword'"
                type="checkbox"
                :data-cell="`cv:${col.cvtId}:${otu.id}`"
                :checked="!!cellData[col.cvtId]?.[otu.id]?.value"
                @change="toggleKeywordCell(col.cvtId, otu.id, $event.target.checked)"
                @keydown.enter.prevent="focusNextRowSameColumn(`cv:${col.cvtId}`, otu.id)"
              />
              <input
                v-else
                type="text"
                class="predicate-cell-input"
                :data-cell="`cv:${col.cvtId}:${otu.id}`"
                :value="cellData[col.cvtId]?.[otu.id]?.value ?? ''"
                @input="setPredicateCell(col.cvtId, otu.id, $event.target.value)"
                @blur="commitPredicateCell(col.cvtId, otu.id)"
                @keydown.enter.prevent="commitPredicateCell(col.cvtId, otu.id); focusNextRowSameColumn(`cv:${col.cvtId}`, otu.id)"
              />
            </div>
            <div
              role="cell"
              class="taxa-grid-addcol"
            />
            <div
              role="cell"
              aria-hidden="true"
              class="taxa-grid-spacer"
            />
          </div>
        </div>
        <div
          v-else
          class="feedback feedback-info padding-small text-center"
        >
          No child taxa are attached to this key. It only cites the
          parent taxon<template v-if="parentOtu">
            <span v-html="' ' + parentOtu.object_tag" />
          </template>. Use
          <a href="#" @click.prevent="goToStep(1)">Step 1</a>
          to add child taxa, or edit the parent citation via the radial
          annotator above.
        </div>
      </template>
    </BlockLayout>
  </template>
</template>

<script setup>
import Autocomplete from '@/components/ui/Autocomplete.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import NavBar from '@/components/layout/NavBar.vue'
import ButtonPinned from '@/components/ui/Button/ButtonPinned.vue'
import OtuPicker from '@/components/otu/otu_picker/otu_picker.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import setParam from '@/helpers/setParam'
import { URLParamsToJSON } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import { usePopstateListener } from '@/composables'
import { Citation, DataAttribute, Lead, Otu, Source, Tag } from '@/routes/endpoints'
import { computed, onBeforeMount, onBeforeUnmount, ref, watch } from 'vue'

const STEPS = [
  { n: 1, label: 'Cite key' },
  { n: 2, label: 'Annotate taxa' }
]

const DESCENDANTS_FILTERS = [
  { value: 'all', label: 'All descendants' },
  { value: 'valid', label: 'Only valid names' }
]

const emptyRoot = () => ({
  id: null,
  text: '',
  otu_id: null,
  is_virtual: false,
  global_id: null
})

const currentStep = ref(1)
const bootLoading = ref(false)
const taxaFullScreen = ref(false)
const root = ref(emptyRoot())
const parentOtu = ref(null)
const source = ref(null)
const pages = ref('')
const species = ref([])
const childLeads = ref({})
const childCitations = ref({})
const originalChildPages = ref({})
const bulkPagesValue = ref('')
const bulkColumnValues = ref({})
const columns = ref([])
const showAddColumn = ref(false)
const newColumnCvt = ref(null)
const cellData = ref({})
const originalCellData = ref({})
const rootCitationId = ref(null)
const originalMetadata = ref(null)
const existingKeys = ref([])
const existingKeysLoading = ref(false)
const loading = ref(false)
const descendantsLoading = ref(false)
const descendantsFilter = ref('valid')
const autoPruneAfterPublication = ref(true)
const pruneMisspellings = ref(true)

const rootId = computed(() => root.value.id)
const rootGlobalId = computed(() => root.value.global_id)

const isAddMode = computed(() => !!rootId.value)

const newSpecies = computed(() =>
  species.value.filter((o) => !childLeads.value[o.id])
)

const gridTemplateColumns = computed(() => {
  const cvCount = columns.value.length
  return ['max-content', 'max-content', 'max-content',
    ...Array(cvCount).fill('max-content'),
    'max-content',
    '1fr'
  ].join(' ')
})

const sortedSpecies = computed(() =>
  [...species.value].sort((a, b) => {
    const aSaved = !!childLeads.value[a.id]
    const bSaved = !!childLeads.value[b.id]
    if (aSaved !== bSaved) return aSaved ? 1 : -1
    const aName = (a.object_tag || a.label_html || '').replace(/<[^>]+>/g, '')
    const bName = (b.object_tag || b.label_html || '').replace(/<[^>]+>/g, '')
    return aName.localeCompare(bName)
  })
)

const sortedSavedSpecies = computed(() =>
  sortedSpecies.value.filter((otu) => !!childLeads.value[otu.id])
)

const dirtyPageOtuIds = computed(() =>
  Object.keys(childCitations.value).filter((otuId) => {
    const cur = childCitations.value[otuId]?.pages ?? ''
    const orig = originalChildPages.value[otuId] ?? ''
    return cur !== orig
  })
)

const dirtyCells = computed(() => {
  const out = []
  Object.entries(cellData.value).forEach(([cvtId, otus]) => {
    Object.entries(otus).forEach(([otuId, cur]) => {
      const orig = originalCellData.value[cvtId]?.[otuId]
      const curVal = cur?.value ?? null
      const origVal = orig?.value ?? null
      if (curVal !== origVal) {
        out.push({ cvtId: Number(cvtId), otuId: Number(otuId), cur, orig })
      }
    })
  })
  return out
})

const isMetadataDirty = computed(() => {
  if (!isAddMode.value || !originalMetadata.value) return false
  return (
    root.value.text.trim() !== originalMetadata.value.text ||
    root.value.otu_id !== originalMetadata.value.otu_id ||
    (source.value?.id ?? null) !== originalMetadata.value.source_id ||
    pages.value !== originalMetadata.value.pages
  )
})

const canSave = computed(() => {
  if (loading.value) return false
  if (isAddMode.value) {
    return (
      newSpecies.value.length > 0 ||
      isMetadataDirty.value ||
      dirtyPageOtuIds.value.length > 0 ||
      dirtyCells.value.length > 0
    )
  }
  return (
    !!root.value.text.trim() &&
    !!parentOtu.value &&
    !!source.value
  )
})

const saveButtonText = computed(() => {
  if (isAddMode.value) {
    const parts = []
    if (isMetadataDirty.value) parts.push('Save metadata changes')
    if (newSpecies.value.length) parts.push(`add ${newSpecies.value.length} taxa`)
    if (dirtyPageOtuIds.value.length) {
      parts.push(`update ${dirtyPageOtuIds.value.length} page(s)`)
    }
    if (dirtyCells.value.length) {
      parts.push(`update ${dirtyCells.value.length} cell(s)`)
    }
    if (parts.length) {
      return parts[0].charAt(0).toUpperCase() + parts[0].slice(1) +
        (parts.length > 1 ? ' and ' + parts.slice(1).join(' and ') : '')
    }
    return ''
  }
  if (!source.value) return 'Pick a source (citation) to enable save'
  if (!root.value.text.trim()) return 'Enter a title to enable save'
  if (!parentOtu.value) return 'Pick a parent OTU to enable save'
  return 'Cite this key'
})

function goToStep(n) {
  if (n === 2 && !rootId.value) return
  currentStep.value = n
}

function selectParent(otu) {
  root.value.otu_id = otu.id
  Otu.find(otu.id).then(({ body }) => {
    parentOtu.value = body
  })
}

function clearParent() {
  parentOtu.value = null
  root.value.otu_id = null
  species.value = []
}

function selectSource(pickedSource) {
  hydrateSource(pickedSource.id)
}

function selectSourceById(id) {
  hydrateSource(id)
}

function hydrateSource(id) {
  return Source.find(id).then(({ body }) => {
    source.value = {
      id: body.id,
      label_html: body.object_tag,
      object_tag: body.object_tag,
      cached_nomenclature_date: body.cached_nomenclature_date,
      year: body.year
    }
  })
}

function clearSource() {
  source.value = null
  pages.value = ''
  existingKeys.value = []
}

watch(source, (newSource) => {
  if (newSource) {
    lookupExistingKeys()
  } else {
    existingKeys.value = []
  }
})

function lookupExistingKeys() {
  existingKeysLoading.value = true
  Citation.all({
    citation_object_type: 'Lead',
    source_id: source.value.id,
    extend: ['citation_object'],
    per: 500
  })
    .then(({ body: citations }) => {
      const rootsMap = new Map()
      citations.forEach((c) => {
        const obj = c.citation_object
        if (!obj || !obj.is_virtual) return
        if (obj.parent_id === null && !rootsMap.has(c.citation_object_id)) {
          rootsMap.set(c.citation_object_id, {
            id: c.citation_object_id,
            text: obj.text,
            pages: c.pages,
            rootTaxonTag: obj.otu?.object_tag ?? null,
            count: 0
          })
        }
      })
      citations.forEach((c) => {
        const obj = c.citation_object
        if (!obj || !obj.is_virtual || obj.parent_id === null) return
        const root = rootsMap.get(obj.parent_id)
        if (root) root.count++
      })
      existingKeys.value = [...rootsMap.values()]
    })
    .catch(() => {
      existingKeys.value = []
    })
    .finally(() => {
      existingKeysLoading.value = false
    })
}

function addSpecies(otu) {
  if (species.value.some((o) => o.id === otu.id)) return
  species.value.push(otu)
}

function looksLikeMisspelling(taxonName) {
  if (!taxonName) return false
  if (taxonName.cached_misspelling) return true
  return /\[sic\]/i.test(taxonName.cached_html ?? '')
}

function taxonDisplay(otu) {
  const tn = otu.taxon_name
  const parts = []
  if (tn?.cached_html) parts.push(tn.cached_html)
  else if (otu.object_tag) parts.push(otu.object_tag)
  else if (otu.label_html) parts.push(otu.label_html)
  else parts.push(`OTU #${otu.id}`)
  if (tn?.cached_author_year) parts.push(tn.cached_author_year)
  if (tn?.cached_is_valid === true) {
    parts.push('<span class="green">&#10004;</span>')
  } else if (tn?.cached_is_valid === false) {
    parts.push('<span class="red">&#10060;</span>')
  }
  return parts.join(' ')
}

function removeSpecies(otuId) {
  species.value = species.value.filter((o) => o.id !== otuId)
}

function clearPendingSpecies() {
  species.value = species.value.filter((o) => !!childLeads.value[o.id])
}

function loadDescendants() {
  if (!parentOtu.value?.taxon_name_id) {
    TW.workbench.alert.create(
      'Parent OTU has no taxon name; cannot load descendants.',
      'error'
    )
    return
  }

  const params = {
    per: 500,
    extend: ['taxon_name'],
    taxon_name_query: {
      taxon_name_id: parentOtu.value.taxon_name_id,
      descendants: true
    }
  }

  if (descendantsFilter.value === 'valid') {
    params.taxon_name_query.validity = true
  }

  descendantsLoading.value = true
  Otu.where(params)
    .then(({ body }) => {
      const sourceDate = source.value?.cached_nomenclature_date
      let prunedByDate = 0
      let prunedByMisspelling = 0
      body.forEach((otu) => {
        if (otu.id === parentOtu.value.id) return
        if (autoPruneAfterPublication.value && sourceDate) {
          const taxonDate = otu.taxon_name?.cached_nomenclature_date
          if (taxonDate && taxonDate > sourceDate) {
            prunedByDate++
            return
          }
        }
        if (pruneMisspellings.value && looksLikeMisspelling(otu.taxon_name)) {
          prunedByMisspelling++
          return
        }
        addSpecies(otu)
      })
      const notes = []
      if (prunedByDate) notes.push(`${prunedByDate} published after the key`)
      if (prunedByMisspelling) notes.push(`${prunedByMisspelling} misspelling(s)`)
      if (notes.length) {
        TW.workbench.alert.create(`Skipped ${notes.join(', ')}.`, 'notice')
      }
    })
    .catch(() => {})
    .finally(() => {
      descendantsLoading.value = false
    })
}

function reset() {
  root.value = emptyRoot()
  parentOtu.value = null
  source.value = null
  pages.value = ''
  species.value = []
  childLeads.value = {}
  childCitations.value = {}
  originalChildPages.value = {}
  bulkPagesValue.value = ''
  bulkColumnValues.value = {}
  columns.value = []
  cellData.value = {}
  originalCellData.value = {}
  cancelAddColumn()
  rootCitationId.value = null
  originalMetadata.value = null
  existingKeys.value = []
  currentStep.value = 1
  setParam(RouteNames.CiteKey, 'lead_id', null)
}

function openAddColumn() {
  showAddColumn.value = true
  newColumnCvt.value = null
}

function cancelAddColumn() {
  showAddColumn.value = false
  newColumnCvt.value = null
}

function pickColumnCvt(item) {
  const type = item?.type
  if (type !== 'Keyword' && type !== 'Predicate') {
    TW.workbench.alert.create(
      `Only Keyword and Predicate vocabulary terms can be used as columns (this is a ${type || 'unknown type'}).`,
      'error'
    )
    newColumnCvt.value = null
    return
  }
  newColumnCvt.value = item
}

function addColumn() {
  if (!newColumnCvt.value) return
  if (columns.value.some((c) => c.cvtId === newColumnCvt.value.id)) {
    cancelAddColumn()
    return
  }
  columns.value.push({
    type: newColumnCvt.value.type === 'Keyword' ? 'keyword' : 'predicate',
    cvtId: newColumnCvt.value.id,
    cvtName: newColumnCvt.value.label || newColumnCvt.value.name
  })
  cancelAddColumn()
}

function removeColumn(cvtId) {
  columns.value = columns.value.filter((c) => c.cvtId !== cvtId)
}

function captureMetadataBaseline() {
  originalMetadata.value = {
    text: root.value.text.trim(),
    otu_id: root.value.otu_id,
    source_id: source.value?.id ?? null,
    pages: pages.value
  }
}

function loadKey(rootLeadId) {
  loading.value = true
  return Lead.find(rootLeadId, { extend: ['otu', 'taxon_name'] })
    .then(({ body }) => {
      const loadedRoot = body.lead
      const loadedChildren = body.children || []

      if (!loadedRoot.is_virtual) {
        window.location.href = `${RouteNames.NewLead}?lead_id=${rootLeadId}`
        return Promise.reject(new Error('redirect'))
      }

      root.value = {
        id: loadedRoot.id,
        text: loadedRoot.text,
        otu_id: loadedRoot.otu_id,
        is_virtual: true,
        global_id: loadedRoot.global_id
      }
      parentOtu.value = loadedRoot.otu
        ? {
            id: loadedRoot.otu.id,
            object_tag: loadedRoot.otu.object_tag,
            taxon_name_id: loadedRoot.otu.taxon_name_id
          }
        : null

      const speciesList = []
      const childMap = {}
      loadedChildren.forEach((child) => {
        const otuObj = child.otu
          ? {
              id: child.otu.id,
              object_tag: child.otu.object_tag,
              taxon_name: child.otu.taxon_name
            }
          : { id: child.otu_id }
        speciesList.push(otuObj)
        childMap[child.otu_id] = {
          id: child.id,
          global_id: child.global_id
        }
      })
      species.value = speciesList
      childLeads.value = childMap

      const allLeadIds = [loadedRoot.id, ...loadedChildren.map((c) => c.id)]
      const otuIdByChildLeadId = {}
      loadedChildren.forEach((c) => {
        otuIdByChildLeadId[c.id] = c.otu_id
      })

      return Citation.all({
        citation_object_type: 'Lead',
        citation_object_id: allLeadIds,
        extend: ['source'],
        per: 500
      }).then(({ body: citations }) => {
        const rootCitation = citations.find(
          (c) => c.citation_object_id === root.value.id
        )
        if (rootCitation) {
          rootCitationId.value = rootCitation.id
          pages.value = rootCitation.pages || ''
          if (rootCitation.source) {
            return hydrateSource(rootCitation.source.id)
          }
        }

        const childCitationMap = {}
        const pageBaseline = {}
        citations.forEach((c) => {
          if (c.citation_object_id === root.value.id) return
          const otuId = otuIdByChildLeadId[c.citation_object_id]
          if (!otuId) return
          childCitationMap[otuId] = { id: c.id, pages: c.pages || '' }
          pageBaseline[otuId] = c.pages || ''
        })
        childCitations.value = childCitationMap
        originalChildPages.value = pageBaseline
      })
    })
    .then(() => loadCellData())
    .then(() => autoPopulateColumns())
    .then(() => {
      currentStep.value = 2
      setParam(RouteNames.CiteKey, 'lead_id', rootLeadId)
      captureMetadataBaseline()
    })
    .catch((err) => {
      if (err?.message !== 'redirect') {
        TW.workbench.alert.create('Failed to load cited key.', 'error')
      }
    })
    .finally(() => {
      loading.value = false
    })
}

function save() {
  if (isAddMode.value) {
    saveChangesToLoadedKey()
  } else {
    createNewKey()
  }
}

function saveChangesToLoadedKey() {
  loading.value = true
  const tasks = []

  if (isMetadataDirty.value) {
    tasks.push(persistMetadataChanges())
  }

  if (newSpecies.value.length) {
    tasks.push(persistNewTaxa())
  }

  if (dirtyPageOtuIds.value.length) {
    tasks.push(persistDirtyPages())
  }

  if (dirtyCells.value.length) {
    tasks.push(persistDirtyCells())
  }

  Promise.all(tasks)
    .then((results) => {
      const messages = results.filter(Boolean)
      if (messages.length) {
        TW.workbench.alert.create(messages.join(' '), 'notice')
      }
    })
    .catch(() => {})
    .finally(() => {
      loading.value = false
    })
}

function persistMetadataChanges() {
  const leadUpdate = Lead.update(root.value.id, {
    lead: {
      text: root.value.text.trim(),
      otu_id: root.value.otu_id,
      is_virtual: true
    }
  })

  const citationUpdate = rootCitationId.value
    ? Citation.update(rootCitationId.value, {
        citation: {
          source_id: source.value.id,
          pages: pages.value.trim() || null
        }
      })
    : Promise.resolve()

  return Promise.all([leadUpdate, citationUpdate]).then(() => {
    captureMetadataBaseline()
    return 'Metadata saved.'
  })
}

function persistNewTaxa() {
  const toAdd = newSpecies.value.slice()

  const childRequests = toAdd.map((otu) =>
    Lead.create({
      lead: {
        parent_id: root.value.id,
        otu_id: otu.id,
        text: null,
        is_virtual: true
      }
    }).then(({ body: childBody }) => ({ otu, createdChild: childBody.lead }))
  )

  return Promise.all(childRequests)
    .then((results) => {
      const newLeadIds = results.map(({ createdChild }) => createdChild.id)
      return Citation.createBatch({
        citation: {
          citation_object_type: 'Lead',
          citation_object_id: newLeadIds,
          source_id: source.value.id,
          pages: null
        }
      }).then(({ body: createdCitations }) => ({ results, createdCitations }))
    })
    .then(({ results, createdCitations }) => {
      const otuByChildLeadId = {}
      results.forEach(({ otu, createdChild }) => {
        otuByChildLeadId[createdChild.id] = otu.id
      })

      const leadMap = { ...childLeads.value }
      results.forEach(({ otu, createdChild }) => {
        leadMap[otu.id] = {
          id: createdChild.id,
          global_id: createdChild.global_id
        }
      })
      childLeads.value = leadMap

      const citationMap = { ...childCitations.value }
      const pageBaseline = { ...originalChildPages.value }
      createdCitations.forEach((citation) => {
        const otuId = otuByChildLeadId[citation.citation_object_id]
        if (!otuId) return
        citationMap[otuId] = { id: citation.id, pages: citation.pages || '' }
        pageBaseline[otuId] = citation.pages || ''
      })
      childCitations.value = citationMap
      originalChildPages.value = pageBaseline

      currentStep.value = 2
      return `${results.length} taxa added.`
    })
}

const savingPages = new Map()

function autoSavePage(otuId) {
  const cell = childCitations.value[otuId]
  if (!cell) return
  const orig = originalChildPages.value[otuId] ?? ''
  const cur = cell.pages ?? ''
  if (cur === orig) return
  if (savingPages.get(otuId)) return

  savingPages.set(otuId, true)
  Citation.update(cell.id, {
    citation: { pages: cur.trim() || null }
  })
    .then(() => {
      originalChildPages.value = {
        ...originalChildPages.value,
        [otuId]: cur
      }
    })
    .catch(() => {
      childCitations.value = {
        ...childCitations.value,
        [otuId]: { ...cell, pages: orig }
      }
    })
    .finally(() => {
      savingPages.delete(otuId)
      const newCur = childCitations.value[otuId]?.pages ?? ''
      const newOrig = originalChildPages.value[otuId] ?? ''
      if (newCur !== newOrig) autoSavePage(otuId)
    })
}

function persistDirtyPages() {
  const dirtyIds = dirtyPageOtuIds.value.slice()

  const requests = dirtyIds.map((otuId) => {
    const cell = childCitations.value[otuId]
    return Citation.update(cell.id, {
      citation: { pages: cell.pages.trim() || null }
    })
  })

  return Promise.all(requests).then(() => {
    const baseline = { ...originalChildPages.value }
    dirtyIds.forEach((otuId) => {
      baseline[otuId] = childCitations.value[otuId].pages
    })
    originalChildPages.value = baseline
    return `${dirtyIds.length} page(s) updated.`
  })
}

function applyBulkColumn(col) {
  const cvtId = col.cvtId
  const target = bulkColumnValues.value[cvtId]
  if (col.type === 'predicate' && (target ?? '') === '') return
  if (col.type === 'keyword' && !target) return

  species.value.forEach((otu) => {
    if (!childLeads.value[otu.id]) return
    if (col.type === 'keyword') {
      toggleKeywordCell(cvtId, otu.id, true)
    } else {
      setPredicateCell(cvtId, otu.id, target)
      autoSaveCell(cvtId, otu.id)
    }
  })

  bulkColumnValues.value = {
    ...bulkColumnValues.value,
    [cvtId]: col.type === 'keyword' ? false : ''
  }
}

function applyBulkPages() {
  const value = bulkPagesValue.value
  const map = { ...childCitations.value }
  species.value.forEach((otu) => {
    const cell = map[otu.id]
    if (cell) map[otu.id] = { ...cell, pages: value }
  })
  childCitations.value = map
}

function autoPopulateColumns() {
  return Lead.citeKeyColumnCvts()
    .then(({ body }) => {
      const existing = new Set(columns.value.map((c) => c.cvtId))
      body.forEach((cvt) => {
        if (existing.has(cvt.id)) return
        columns.value.push({
          type: cvt.type === 'Keyword' ? 'keyword' : 'predicate',
          cvtId: cvt.id,
          cvtName: cvt.name
        })
      })
    })
    .catch(() => {})
}

function loadCellData() {
  const leadIds = Object.values(childLeads.value).map((c) => c.id)
  if (!leadIds.length) {
    cellData.value = {}
    originalCellData.value = {}
    return Promise.resolve()
  }

  const otuByLeadId = {}
  Object.entries(childLeads.value).forEach(([otuId, { id }]) => {
    otuByLeadId[id] = Number(otuId)
  })

  const daPromise = DataAttribute.all({
    attribute_subject_id: leadIds,
    attribute_subject_type: 'Lead',
    per: 500
  })
  const tagPromise = Tag.all({
    tag_object_id: leadIds,
    tag_object_type: 'Lead',
    per: 500
  })

  return Promise.all([daPromise, tagPromise]).then(
    ([{ body: das }, { body: tags }]) => {
      const cd = {}
      das.forEach((da) => {
        const otuId = otuByLeadId[da.attribute_subject_id]
        if (!otuId) return
        const cvtId = da.controlled_vocabulary_term_id
        if (!cd[cvtId]) cd[cvtId] = {}
        cd[cvtId][otuId] = { id: da.id, value: da.value ?? '' }
      })
      tags.forEach((tag) => {
        const otuId = otuByLeadId[tag.tag_object_id]
        if (!otuId) return
        const cvtId = tag.keyword_id
        if (!cd[cvtId]) cd[cvtId] = {}
        cd[cvtId][otuId] = { id: tag.id, value: true }
      })
      cellData.value = cd
      originalCellData.value = deepClone(cd)
    }
  ).catch(() => {})
}

function deepClone(obj) {
  return JSON.parse(JSON.stringify(obj))
}

function setPredicateCell(cvtId, otuId, value) {
  if (!cellData.value[cvtId]) cellData.value[cvtId] = {}
  const cur = cellData.value[cvtId][otuId] ?? { id: null, value: '' }
  cellData.value[cvtId] = {
    ...cellData.value[cvtId],
    [otuId]: { ...cur, value }
  }
}

function toggleKeywordCell(cvtId, otuId, checked) {
  if (!cellData.value[cvtId]) cellData.value[cvtId] = {}
  const cur = cellData.value[cvtId][otuId] ?? { id: null, value: false }
  cellData.value[cvtId] = {
    ...cellData.value[cvtId],
    [otuId]: { ...cur, value: !!checked }
  }
  autoSaveCell(cvtId, otuId)
}

function commitPredicateCell(cvtId, otuId) {
  autoSaveCell(cvtId, otuId)
}

function focusNextRowSameColumn(colKey, currentOtuId) {
  const sorted = sortedSpecies.value
  const idx = sorted.findIndex((o) => o.id === currentOtuId)
  if (idx < 0 || idx >= sorted.length - 1) return
  const nextOtuId = sorted[idx + 1].id
  const selector = `[data-cell="${colKey}:${nextOtuId}"]`
  const next = document.querySelector(selector)
  if (next) {
    next.focus()
    if (typeof next.select === 'function') next.select()
  }
}

const savingCells = new Map()

function autoSaveCell(cvtId, otuId) {
  const cellKey = `${cvtId}:${otuId}`
  if (savingCells.get(cellKey)) return

  const col = columns.value.find((c) => c.cvtId === cvtId)
  const childLead = childLeads.value[otuId]
  if (!col || !childLead) return

  const cur = cellData.value[cvtId]?.[otuId]
  const orig = originalCellData.value[cvtId]?.[otuId]
  const curVal = cur?.value ?? null
  const origVal = orig?.value ?? null
  if (curVal === origVal) return

  savingCells.set(cellKey, true)
  const releaseAndRecheck = () => {
    savingCells.delete(cellKey)
    const newCur = cellData.value[cvtId]?.[otuId]
    const newOrig = originalCellData.value[cvtId]?.[otuId]
    if ((newCur?.value ?? null) !== (newOrig?.value ?? null)) {
      autoSaveCell(cvtId, otuId)
    }
  }

  const rebaseline = (updated) => {
    const map = { ...(originalCellData.value[cvtId] ?? {}) }
    if (updated === null) {
      delete map[otuId]
    } else {
      map[otuId] = updated
    }
    originalCellData.value = {
      ...originalCellData.value,
      [cvtId]: map
    }
    if (updated) {
      cellData.value[cvtId] = {
        ...cellData.value[cvtId],
        [otuId]: updated
      }
    } else if (cellData.value[cvtId]) {
      const cd = { ...cellData.value[cvtId] }
      delete cd[otuId]
      cellData.value[cvtId] = cd
    }
    releaseAndRecheck()
  }

  const revert = () => {
    if (orig) {
      cellData.value[cvtId] = {
        ...cellData.value[cvtId],
        [otuId]: { ...orig }
      }
    } else if (cellData.value[cvtId]) {
      const cd = { ...cellData.value[cvtId] }
      delete cd[otuId]
      cellData.value[cvtId] = cd
    }
    savingCells.delete(cellKey)
  }

  if (col.type === 'predicate') {
    const value = (cur?.value ?? '').toString()
    if (cur?.id) {
      if (value === '') {
        DataAttribute.destroy(cur.id)
          .then(() => rebaseline(null))
          .catch(revert)
      } else {
        DataAttribute.update(cur.id, { data_attribute: { value } })
          .then(({ body }) => rebaseline({ id: body.id ?? cur.id, value }))
          .catch(revert)
      }
    } else if (value !== '') {
      DataAttribute.create({
        data_attribute: {
          attribute_subject_type: 'Lead',
          attribute_subject_id: childLead.id,
          controlled_vocabulary_term_id: cvtId,
          type: 'InternalAttribute',
          value
        }
      })
        .then(({ body }) => rebaseline({ id: body.id, value }))
        .catch(revert)
    } else {
      rebaseline(null)
    }
    return
  }

  // Keyword
  const wantTag = !!cur?.value
  if (wantTag && !orig?.id) {
    Tag.create({
      tag: {
        keyword_id: cvtId,
        tag_object_type: 'Lead',
        tag_object_id: childLead.id
      }
    })
      .then(({ body }) => rebaseline({ id: body.id, value: true }))
      .catch(revert)
  } else if (!wantTag && orig?.id) {
    Tag.destroy(orig.id)
      .then(() => rebaseline(null))
      .catch(revert)
  }
}

function persistDirtyCells() {
  const dirty = dirtyCells.value.slice()
  if (!dirty.length) return Promise.resolve(null)

  const requests = dirty.map(({ cvtId, otuId, cur, orig }) => {
    const col = columns.value.find((c) => c.cvtId === cvtId)
    const childLead = childLeads.value[otuId]
    if (!col || !childLead) return Promise.resolve()

    if (col.type === 'predicate') {
      const value = cur?.value ?? ''
      if (cur?.id) {
        if (value === '') {
          return DataAttribute.destroy(cur.id)
        }
        return DataAttribute.update(cur.id, {
          data_attribute: { value }
        })
      }
      if (value === '') return Promise.resolve()
      return DataAttribute.create({
        data_attribute: {
          attribute_subject_type: 'Lead',
          attribute_subject_id: childLead.id,
          controlled_vocabulary_term_id: cvtId,
          type: 'InternalAttribute',
          value
        }
      })
    }

    // Keyword
    const wantTag = !!cur?.value
    if (wantTag && !orig?.id) {
      return Tag.create({
        tag: {
          keyword_id: cvtId,
          tag_object_type: 'Lead',
          tag_object_id: childLead.id
        }
      })
    }
    if (!wantTag && orig?.id) {
      return Tag.destroy(orig.id)
    }
    return Promise.resolve()
  })

  return Promise.all(requests).then(() => {
    return loadCellData().then(() => `${dirty.length} cell(s) updated.`)
  })
}

function deleteChildLead(otu) {
  const child = childLeads.value[otu.id]
  if (!child) return
  const name = otu.object_tag || otu.label_html || `OTU #${otu.id}`
  const el = document.createElement('div')
  el.innerHTML = name
  const clean = el.textContent.trim()
  if (!window.confirm(`Permanently delete ${clean} from this key?`)) return

  loading.value = true
  Lead.destroy(child.id)
    .then(() => {
      species.value = species.value.filter((o) => o.id !== otu.id)
      const leadMap = { ...childLeads.value }
      delete leadMap[otu.id]
      childLeads.value = leadMap
      const citationMap = { ...childCitations.value }
      delete citationMap[otu.id]
      childCitations.value = citationMap
      const baseline = { ...originalChildPages.value }
      delete baseline[otu.id]
      originalChildPages.value = baseline
      TW.workbench.alert.create(`${clean} removed from key.`, 'notice')
    })
    .catch(() => {})
    .finally(() => {
      loading.value = false
    })
}

function createNewKey() {
  loading.value = true

  const rootPayload = {
    lead: {
      text: root.value.text.trim(),
      otu_id: root.value.otu_id,
      is_virtual: true
    }
  }

  Lead.create(rootPayload)
    .then(({ body }) => {
      const createdRoot = body.lead
      const childRequests = species.value.map((otu) =>
        Lead.create({
          lead: {
            parent_id: createdRoot.id,
            otu_id: otu.id,
            text: null,
            is_virtual: true
          }
        }).then(({ body: childBody }) => ({ otu, createdChild: childBody.lead }))
      )

      return Promise.all(childRequests).then((results) => ({
        createdRoot,
        results
      }))
    })
    .then(({ createdRoot, results }) => {
      const rootCitation = Citation.create({
        citation: {
          citation_object_type: 'Lead',
          citation_object_id: createdRoot.id,
          source_id: source.value.id,
          pages: pages.value.trim() || null
        }
      })
      const childCitationBatch = results.length
        ? Citation.createBatch({
            citation: {
              citation_object_type: 'Lead',
              citation_object_id: results.map(({ createdChild }) => createdChild.id),
              source_id: source.value.id,
              pages: null
            }
          })
        : Promise.resolve({ body: [] })
      return Promise.all([rootCitation, childCitationBatch]).then(() => ({
        createdRoot,
        results
      }))
    })
    .then(({ createdRoot, results }) => {
      TW.workbench.alert.create(
        `Key citation created with ${results.length} taxa.`,
        'notice'
      )
      return loadKey(createdRoot.id)
    })
    .catch(() => {})
    .finally(() => {
      loading.value = false
    })
}

usePopstateListener(() => {
  const { lead_id } = URLParamsToJSON(location.href)
  if (lead_id) {
    loadKey(Number(lead_id))
  } else {
    reset()
  }
})

onBeforeMount(() => {
  const { lead_id } = URLParamsToJSON(location.href)
  if (lead_id) {
    bootLoading.value = true
    loadKey(Number(lead_id)).finally(() => {
      bootLoading.value = false
    })
  }
  document.addEventListener('keydown', handleFullScreenEscape)
})

onBeforeUnmount(() => {
  document.removeEventListener('keydown', handleFullScreenEscape)
})

function handleFullScreenEscape(e) {
  if (e.key === 'Escape' && taxaFullScreen.value) {
    taxaFullScreen.value = false
  }
}
</script>

<style scoped>
.header-radials {
  margin-right: .5em;
}

.no-style-list {
  list-style: none;
  padding-left: 0;
}

.step-nav {
  padding-left: 0;
  margin: 0;
}

.cite-key-navbar {
  margin-bottom: 1rem;
}

.step-item {
  color: var(--text-muted-color, #666);
  cursor: default;
}

.step-item.step-active,
.step-item.step-done {
  color: inherit;
  cursor: pointer;
}

.step-number {
  width: 1.75rem;
  height: 1.75rem;
  border-radius: 50%;
  border: 1px solid currentColor;
  font-weight: bold;
}

.step-item.step-active .step-number {
  background-color: var(--color-primary);
  color: var(--color-on-primary, white);
  border-color: var(--color-primary);
}

.step-item.step-done .step-number {
  background-color: var(--text-muted-color);
  color: white;
  border-color: var(--text-muted-color);
}

.species-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 0.25rem 1rem;
}

.species-row {
  min-width: 0;
}

.species-row-saved {
  color: var(--text-muted-color);
}

.taxa-grid {
  display: grid;
  width: 100%;
  max-height: 70vh;
  overflow: auto;
}

.fullscreen-toggle {
  cursor: pointer;
}

.taxa-fullscreen {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 1000;
  margin: 0 !important;
  border-radius: 0;
  max-width: none;
  overflow: auto;
}

.taxa-fullscreen .taxa-grid {
  max-height: calc(100vh - 6rem);
}

.taxa-grid-row {
  display: grid;
  grid-template-columns: subgrid;
  grid-column: 1 / -1;
}

.taxa-grid-row > * {
  padding: 0.35rem 0.75rem;
  display: flex;
  align-items: center;
  min-width: 0;
  white-space: nowrap;
}

.taxa-grid > .taxa-grid-row:not(.taxa-grid-header):nth-child(even) {
  background: var(--table-row-bg-odd);
}

.taxa-grid-header {
  position: sticky;
  top: 0;
  z-index: 1;
  background: var(--bg-action);
}

.taxa-grid-header > * {
  align-items: flex-start;
  padding-top: 0.5rem;
  padding-bottom: 0.5rem;
  font-weight: bold;
}

.add-column-picker {
  min-width: 16rem;
}

.predicate-cell-input {
  width: 18rem;
}

.add-column-picker .add-column-autocomplete {
  width: 100%;
}
</style>

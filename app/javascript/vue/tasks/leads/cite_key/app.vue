<template>
  <VSpinner
    v-if="loading"
    full-screen
  />

  <h1>{{ isAddMode ? 'Edit cited key' : 'Cite a key' }}</h1>

  <NavBar navbar-class="panel content cite-key-navbar">
    <div class="flex-separate middle">
      <div />
      <div class="d-flex middle gap-small">
        <VBtn
          v-if="!isAddMode || canSave"
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

  <template v-if="!bootLoading">
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
            placeholder="Optional"
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
        <div class="flex-separate middle full_width">
          <h3>Key metadata</h3>
          <div
            v-if="rootGlobalId"
            class="horizontal-right-content gap-small header-radials"
          >
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

        <p
          v-if="rootGlobalId"
          class="small_type margin-small-top"
        >
          Use the radial annotator above to record attributes that apply to the
          whole key (sex, life stage, etc.).
        </p>
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
import { LinkerStorage } from '@/shared/Filter/utils'
import { RouteNames } from '@/routes/routes'
import { usePopstateListener } from '@/composables'
import { Citation, Lead, Otu, Source } from '@/routes/endpoints'
import { computed, onBeforeMount, ref, watch } from 'vue'

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

const bootLoading = ref(false)
const root = ref(emptyRoot())
const parentOtu = ref(null)
const source = ref(null)
const pages = ref('')
const species = ref([])
const childLeads = ref({})
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

const sortedSpecies = computed(() =>
  [...species.value].sort((a, b) => {
    const aSaved = !!childLeads.value[a.id]
    const bSaved = !!childLeads.value[b.id]
    if (aSaved !== bSaved) return aSaved ? 1 : -1
    const aName = stripHtml(a.object_tag || a.label_html || '')
    const bName = stripHtml(b.object_tag || b.label_html || '')
    return aName.localeCompare(bName)
  })
)

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
    return newSpecies.value.length > 0 || isMetadataDirty.value
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

function stripHtml(str) {
  if (str == null) return ''
  const el = document.createElement('div')
  el.innerHTML = String(str)
  return el.textContent ?? ''
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
  rootCitationId.value = null
  originalMetadata.value = null
  existingKeys.value = []
  setParam(RouteNames.CiteKey, 'lead_id', null)
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

      return Citation.all({
        citation_object_type: 'Lead',
        citation_object_id: loadedRoot.id,
        extend: ['source'],
        per: 10
      }).then(({ body: citations }) => {
        const rootCitation = citations[0]
        if (rootCitation) {
          rootCitationId.value = rootCitation.id
          pages.value = rootCitation.pages || ''
          if (rootCitation.source) {
            return hydrateSource(rootCitation.source.id)
          }
        }
      })
    })
    .then(() => {
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

  return Promise.all(childRequests).then((results) => {
    const leadMap = { ...childLeads.value }
    results.forEach(({ otu, createdChild }) => {
      leadMap[otu.id] = {
        id: createdChild.id,
        global_id: createdChild.global_id
      }
    })
    childLeads.value = leadMap
    return `${results.length} taxa added.`
  })
}

function deleteChildLead(otu) {
  const child = childLeads.value[otu.id]
  if (!child) return
  const name = otu.object_tag || otu.label_html || `OTU #${otu.id}`
  const clean = stripHtml(name).trim()
  if (!window.confirm(`Permanently delete ${clean} from this key?`)) return

  loading.value = true
  Lead.destroy(child.id)
    .then(() => {
      species.value = species.value.filter((o) => o.id !== otu.id)
      const leadMap = { ...childLeads.value }
      delete leadMap[otu.id]
      childLeads.value = leadMap
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
      return Citation.create({
        citation: {
          citation_object_type: 'Lead',
          citation_object_id: createdRoot.id,
          source_id: source.value.id,
          pages: pages.value.trim() || null
        }
      }).then(() => ({ createdRoot, results }))
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
  const parsed = URLParamsToJSON(location.href)
  const { lead_id } = parsed
  let otuIds = parsed.otu_ids
  let otuQuery = parsed.otu_query
  if (!otuIds?.length && !otuQuery) {
    const saved = LinkerStorage.getParameters()
    if (saved?.otu_ids?.length || saved?.otu_query) {
      otuIds = saved.otu_ids
      otuQuery = saved.otu_query
      LinkerStorage.removeParameters()
    }
  }

  if (lead_id) {
    bootLoading.value = true
    loadKey(Number(lead_id)).finally(() => {
      bootLoading.value = false
    })
  } else if (otuIds?.length || otuQuery) {
    bootLoading.value = true
    bootstrapFromOtus({ otuIds, otuQuery }).finally(() => {
      bootLoading.value = false
    })
  }
})

function bootstrapFromOtus({ otuIds, otuQuery }) {
  return Lead.citeKeyBootstrap({ otuIds, otuQuery })
    .then(({ body }) => {
      if (body.parent_otu) {
        parentOtu.value = {
          id: body.parent_otu.id,
          object_tag: body.parent_otu.object_tag,
          taxon_name_id: body.parent_otu.taxon_name?.id
        }
        root.value.otu_id = body.parent_otu.id
      }
      body.otus.forEach((otu) => addSpecies(otu))
      const truncationNote = body.truncated
        ? ` (capped at ${body.otus.length} of ${body.total}; refine the filter or split the key)`
        : ''
      const parentNote = body.parent_otu
        ? 'parent inferred as ' + stripHtml(body.parent_otu.object_tag)
        : 'no shared parent inferred'
      TW.workbench.alert.create(
        `Prefilled ${body.otus.length} taxa from Filter OTUs${truncationNote}; ` +
          parentNote +
          '. Pick a source and title, then Cite this key.',
        body.truncated ? 'warning' : 'notice'
      )
    })
    .catch(() => {})
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

.cite-key-navbar {
  margin-bottom: 1rem;
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
</style>

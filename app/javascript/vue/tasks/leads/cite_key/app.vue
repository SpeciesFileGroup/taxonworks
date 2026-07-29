<template>
  <VSpinner
    v-if="loading"
    full-screen
  />

  <div class="flex-separate middle margin-medium-bottom">
    <h1>{{ currentStep === 1 ? (isAddMode ? 'Edit cited key' : 'Cite a key') : 'Annotate cited key' }}</h1>
    <VBtn
      v-if="rootId"
      color="primary"
      @click="reset"
    >
      Cite a new key
    </VBtn>
  </div>

  <ol class="step-nav no-style-list d-flex gap-medium middle margin-medium-bottom">
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

  <!-- Step 1: Create key + species list -->
  <template v-if="currentStep === 1">
    <BlockLayout expand>
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
          <ul
            v-else-if="existingKeys.length"
            class="no-style-list panel content margin-small-top"
          >
            <li
              v-for="key in existingKeys"
              :key="key.id"
              class="d-flex flex-separate middle padding-xsmall separate-bottom"
            >
              <span>{{ key.text }}</span>
              <VBtn
                color="primary"
                @click="loadKey(key.id)"
              >
                Open
              </VBtn>
            </li>
          </ul>
          <div
            v-else
            class="small_type padding-xsmall"
          >
            No existing cited keys for this source. Fill out the fields below to record a new one.
          </div>
        </div>
      </template>
    </BlockLayout>

    <BlockLayout expand>
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
          <VBtn
            color="primary"
            :disabled="!species.length"
            @click="species = []"
          >
            Clear list
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
            v-for="otu in species"
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
              v-html="otu.object_tag || otu.label_html || `OTU #${otu.id}`"
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

    <div
      v-if="!isAddMode || canSave"
      class="text-center margin-medium-top"
    >
      <VBtn
        color="create"
        medium
        :disabled="!canSave"
        @click="save"
      >
        {{ saveButtonText }}
      </VBtn>
    </div>
  </template>

  <!-- Step 2: Annotate species -->
  <template v-else>
    <BlockLayout expand>
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

    <BlockLayout expand>
      <template #header>
        <h3>Taxa in key ({{ species.length }})</h3>
      </template>

      <template #body>
        <ul
          v-if="species.length"
          class="no-style-list panel content species-grid"
        >
          <li
            v-for="otu in species"
            :key="otu.id"
            class="d-flex middle gap-small padding-xsmall species-row"
          >
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
            <span
              class="ellipsis"
              v-html="otu.object_tag || otu.label_html || `OTU #${otu.id}`"
            />
          </li>
        </ul>
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
import { Citation, Lead, Otu, Source } from '@/routes/endpoints'
import { computed, onBeforeMount, ref, watch } from 'vue'

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
const descendantsFilter = ref('all')

const rootId = computed(() => root.value.id)
const rootGlobalId = computed(() => root.value.global_id)

const isAddMode = computed(() => !!rootId.value)

const newSpecies = computed(() =>
  species.value.filter((o) => !childLeads.value[o.id])
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
    return parts.length ? parts.join(' and ') : ''
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
  source.value = pickedSource
}

function selectSourceById(id) {
  Source.find(id).then(({ body }) => {
    source.value = {
      id: body.id,
      label_html: body.object_tag,
      object_tag: body.object_tag
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
  Citation.where({
    citation_object_type: 'Lead',
    source_id: source.value.id,
    extend: ['citation_object']
  })
    .then(({ body: citations }) => {
      const seen = new Set()
      const roots = []
      citations.forEach((c) => {
        const obj = c.citation_object
        if (!obj || !obj.is_virtual || obj.parent_id !== null) return
        if (seen.has(c.citation_object_id)) return
        seen.add(c.citation_object_id)
        roots.push({ id: c.citation_object_id, text: obj.text })
      })
      existingKeys.value = roots
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

function removeSpecies(otuId) {
  species.value = species.value.filter((o) => o.id !== otuId)
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
      body.forEach((otu) => {
        if (otu.id !== parentOtu.value.id) addSpecies(otu)
      })
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
  currentStep.value = 1
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
  return Lead.find(rootLeadId, { extend: ['otu'] })
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
              object_tag: child.otu.object_tag
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
      return Citation.where({
        citation_object_type: 'Lead',
        citation_object_id: allLeadIds,
        extend: ['source']
      }).then(({ body: citations }) => {
        const rootCitation = citations.find(
          (c) => c.citation_object_id === root.value.id
        )
        if (rootCitation) {
          rootCitationId.value = rootCitation.id
          if (rootCitation.source) {
            source.value = {
              id: rootCitation.source.id,
              label_html: rootCitation.source.object_tag,
              object_tag: rootCitation.source.object_tag
            }
          }
          pages.value = rootCitation.pages || ''
        }
      })
    })
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
          pages: pages.value.trim() || null
        }
      }).then(() => results)
    })
    .then((results) => {
      const map = { ...childLeads.value }
      results.forEach(({ otu, createdChild }) => {
        map[otu.id] = {
          id: createdChild.id,
          global_id: createdChild.global_id
        }
      })
      childLeads.value = map
      currentStep.value = 2
      return `${results.length} taxa added.`
    })
}

function deleteChildLead(otu) {
  const child = childLeads.value[otu.id]
  if (!child) return
  const name = otu.object_tag || otu.label_html || `OTU #${otu.id}`
  const clean = name.replace(/<[^>]+>/g, '')
  if (!window.confirm(`Permanently delete ${clean} from this key?`)) return

  loading.value = true
  Lead.destroy(child.id)
    .then(() => {
      species.value = species.value.filter((o) => o.id !== otu.id)
      const map = { ...childLeads.value }
      delete map[otu.id]
      childLeads.value = map
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
      const leadIds = [
        createdRoot.id,
        ...results.map(({ createdChild }) => createdChild.id)
      ]
      return Citation.createBatch({
        citation: {
          citation_object_type: 'Lead',
          citation_object_id: leadIds,
          source_id: source.value.id,
          pages: pages.value.trim() || null
        }
      }).then(() => ({ createdRoot, results }))
    })
    .then(({ createdRoot, results }) => {
      root.value = {
        id: createdRoot.id,
        text: createdRoot.text,
        otu_id: createdRoot.otu_id,
        is_virtual: true,
        global_id: createdRoot.global_id
      }
      const map = {}
      results.forEach(({ otu, createdChild }) => {
        map[otu.id] = {
          id: createdChild.id,
          global_id: createdChild.global_id
        }
      })
      childLeads.value = map
      currentStep.value = 2
      setParam(RouteNames.CiteKey, 'lead_id', createdRoot.id)
      TW.workbench.alert.create(
        `Key citation created with ${results.length} taxa.`,
        'notice'
      )
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
    loadKey(Number(lead_id))
  }
})
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
  margin: 0 0 1rem 0;
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
  background-color: var(--color-create, currentColor);
  color: var(--color-on-create, white);
  border-color: var(--color-create);
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
</style>

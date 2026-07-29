<template>
  <VSpinner
    v-if="loading"
    full-screen
  />

  <div class="flex-separate middle margin-medium-bottom">
    <h1>{{ currentStep === 1 ? 'New virtual key' : 'Annotate virtual key' }}</h1>
    <VBtn
      v-if="rootId"
      color="primary"
      @click="reset"
    >
      Start a new virtual key
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
      :set-expanded="!!parentOtu"
    >
      <template #header>
        <h3>Species in key ({{ species.length }})</h3>
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
            class="d-flex middle gap-small padding-xsmall species-row"
          >
            <span
              class="button button-circle btn-undo button-default"
              title="Remove from list"
              @click="removeSpecies(otu.id)"
            />
            <span
              class="ellipsis"
              v-html="otu.object_tag || otu.label_html"
            />
          </li>
        </ul>
        <div
          v-else
          class="feedback feedback-info padding-small text-center"
        >
          No species added. Pick a parent OTU and click
          <em>Add descendants</em>, or add OTUs individually above.
        </div>
      </template>
    </BlockLayout>

    <div class="text-center margin-medium-top">
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
          <div
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
          <div>{{ root.text }}</div>
        </div>
        <div class="field label-above">
          <label>Parent OTU</label>
          <div v-if="parentOtu" v-html="parentOtu.object_tag" />
        </div>
      </template>
    </BlockLayout>

    <BlockLayout expand>
      <template #header>
        <h3>Species in key ({{ species.length }})</h3>
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
              class="ellipsis"
              v-html="otu.object_tag || otu.label_html"
            />
          </li>
        </ul>
      </template>
    </BlockLayout>
  </template>
</template>

<script setup>
import Autocomplete from '@/components/ui/Autocomplete.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import OtuPicker from '@/components/otu/otu_picker/otu_picker.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { Lead, Otu } from '@/routes/endpoints'
import { computed, ref } from 'vue'

const STEPS = [
  { n: 1, label: 'Create virtual key' },
  { n: 2, label: 'Annotate species' }
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
const species = ref([])
const childLeads = ref({})
const loading = ref(false)
const descendantsLoading = ref(false)
const descendantsFilter = ref('all')

const rootId = computed(() => root.value.id)
const rootGlobalId = computed(() => root.value.global_id)

const canSave = computed(() =>
  !rootId.value && !!root.value.text.trim() && !!parentOtu.value && !loading.value
)

const saveButtonText = computed(() => {
  if (!root.value.text.trim()) return 'Enter a title to enable save'
  if (!parentOtu.value) return 'Pick a parent OTU to enable save'
  return 'Create virtual key'
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
  species.value = []
  childLeads.value = {}
  currentStep.value = 1
}

function save() {
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
      TW.workbench.alert.create(
        `Virtual key created with ${results.length} species.`,
        'notice'
      )
    })
    .catch(() => {})
    .finally(() => {
      loading.value = false
    })
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
</style>

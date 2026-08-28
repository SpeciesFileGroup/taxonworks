<template>
  <VSpinner
    v-if="loading || bootLoading"
    full-screen
  />

  <NavBar navbar-class="panel content cite-key-navbar">
    <div class="flex-separate middle">
      <div />
      <div class="d-flex middle gap-small">
        <Recent @selected="(item) => loadKey(item.id)" />
        <VBtn
          v-if="rootId"
          medium
          color="primary"
          @click="reset"
        >
          Add a new simple key
        </VBtn>
        <VBtn
          medium
          color="create"
          :disabled="!canSave"
          @click="save"
        >
          Save
        </VBtn>
      </div>
    </div>
  </NavBar>

  <BlockLayout
    expand
    class="margin-medium-bottom"
  >
    <template #header>
      <h3>Citation</h3>
    </template>

    <template #body>
      <FormCitation
        :fieldset="false"
        :new-button="false"
        :original="false"
        v-model="citationData"
        :klass="LEAD"
        @source="onSourceSelected"
      />

      <div
        v-if="source"
        class="separate-top margin-medium-top"
      >
        <label class="font-bold">Existing simple keys for this source</label>
        <div
          v-if="existingKeysLoading"
          class="small_type padding-xsmall"
        >
          Checking for existing keys…
        </div>
        <table
          v-else-if="existingKeys.length"
          class="full_width margin-small-top"
        >
          <thead>
            <tr>
              <th>Title</th>
              <th>Root OTU</th>
              <th>Taxa</th>
              <th>Pages</th>
              <th>Updated</th>
              <th>By</th>
              <th />
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(key, index) in existingKeys"
              :key="key.id"
              class="contextMenuCells"
              :class="{ even: index % 2 == 0 }"
              @dblclick="() => loadKey(key.id)"
            >
              <td>{{ key.text }}</td>
              <td v-html="key.rootTaxonTag ?? '—'" />
              <td>{{ key.count }}</td>
              <td>{{ key.pages || '—' }}</td>
              <td>{{ key.updated_at_in_words ? `${key.updated_at_in_words} ago` : '—' }}</td>
              <td>{{ key.updated_by ?? '—' }}</td>
              <td>
                <VBtn
                  circle
                  color="primary"
                  @click="() => loadKey(key.id)"
                >
                  <VIcon
                    name="pencil"
                    x-small
                  />
                </VBtn>
              </td>
            </tr>
          </tbody>
        </table>
        <div
          v-else
          class="small_type padding-xsmall"
        >
          No existing simple keys for this source. Fill out the fields below to record a new one.
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
          <label>Description</label>
          <textarea
            class="full_width"
            v-model="root.description"
            rows="2"
          />
        </div>

        <div class="field label-above margin-medium-top">
          <label>Parent OTU</label>
          <div
            v-if="parentOtu"
            class="d-flex middle gap-small flex-wrap-row"
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
            <label
              class="d-flex middle gap-small margin-medium-left"
              :title="parentOtu?.taxon_name_id
                ? 'Fetch and add all descendant taxa on save'
                : 'Parent OTU has no taxon name; cannot add descendants'"
            >
              <input
                type="checkbox"
                v-model="addDescendantsOnSave"
                :disabled="!parentOtu?.taxon_name_id"
              />
              Add descendants on save
            </label>
            <label
              v-if="addDescendantsOnSave"
              class="d-flex middle gap-medium"
            >
              <span class="margin-small-right">Filter</span>
              <select v-model="descendantsFilter">
                <option
                  v-for="opt in DESCENDANTS_FILTERS"
                  :key="opt.value"
                  :value="opt.value"
                >
                  {{ opt.label }}
                </option>
              </select>
            </label>
          </div>
          <OtuPicker
            v-else
            :clear-after="true"
            @get-item="selectParent"
          />
        </div>

        <div class="field">
          <label>
            <input
              type="checkbox"
              v-model="root.is_public"
            />
            Is publicly accessible?
          </label>
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
      v-if="rootId"
      expand
      class="margin-medium-bottom"
    >
      <template #header>
        <h3>Tags</h3>
      </template>

      <template #body>
        <div
          v-if="!leadKeywords.length && !tags.length"
          class="small_type padding-xsmall"
        >
          No tags have been applied to any keys in this project yet. Add one via
          the radial annotator above.
        </div>

        <template v-else>
          <label class="font-bold">Attached to this key</label>
          <div
            v-if="tags.length"
            class="d-flex flex-wrap-row gap-small margin-small-top margin-medium-bottom"
          >
            <span
              v-for="tag in attachedTags"
              :key="tag.id"
              class="pill keyword keyword-clickable"
              role="button"
              tabindex="0"
              :style="keywordPillStyle(tag.keyword)"
              :title="`${tag.keyword?.name}${tag.keyword?.definition ? ' — ' + tag.keyword.definition : ''} (click to remove)`"
              @click="!tagsBusy && removeTag(tag)"
              @keydown.enter.prevent="!tagsBusy && removeTag(tag)"
              @keydown.space.prevent="!tagsBusy && removeTag(tag)"
            >
              <span>{{ tag.keyword?.name }} <span
                aria-hidden="true"
                class="tag-remove"
              >×</span></span>
            </span>
          </div>
          <div
            v-else
            class="small_type padding-xsmall margin-medium-bottom"
          >
            None yet — click a tag below to attach it.
          </div>

          <label class="font-bold">Available tags</label>
          <div
            v-if="unattachedKeywords.length"
            class="d-flex flex-wrap-row gap-small margin-small-top"
          >
            <span
              v-for="keyword in unattachedKeywords"
              :key="keyword.id"
              class="pill keyword keyword-clickable keyword-outline"
              role="button"
              tabindex="0"
              :style="keywordOutlineStyle(keyword)"
              :title="`${keyword.name}${keyword.definition ? ' — ' + keyword.definition : ''} (click to attach)`"
              @click="!tagsBusy && attachKeyword(keyword)"
              @keydown.enter.prevent="!tagsBusy && attachKeyword(keyword)"
              @keydown.space.prevent="!tagsBusy && attachKeyword(keyword)"
            >
              <span>{{ keyword.name }}</span>
            </span>
          </div>
          <div
            v-else
            class="small_type padding-xsmall"
          >
            All existing tags are already attached.
          </div>
        </template>
      </template>
    </BlockLayout>

    <BlockLayout
      v-if="rootId"
      expand
      class="margin-medium-bottom"
    >
      <template #header>
        <h3>Taxa in key ({{ species.length }})</h3>
      </template>

      <template #body>
        <div class="d-flex gap-small middle margin-medium-bottom flex-wrap-row">
          <VBtn
            color="destroy"
            :disabled="!publishedAfterCount"
            :title="source?.cached_nomenclature_date
              ? `Remove taxa published after ${source.cached_nomenclature_date}`
              : 'Pick a source with a publication date to enable'"
            @click="removePublishedAfter"
          >
            Remove taxa published after the key ({{ publishedAfterCount }})
          </VBtn>
          <VBtn
            color="destroy"
            :disabled="!misspellingCount"
            title="Remove taxa flagged as misspellings (cached_misspelling or [sic] in the name)"
            @click="removeMisspellings"
          >
            Remove misspellings ({{ misspellingCount }})
          </VBtn>
          <VBtn
            color="destroy"
            :disabled="!species.length"
            title="Delete every taxon from this key so you can start over"
            @click="deleteAllChildren"
          >
            Delete all taxa ({{ species.length }})
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
            @get-item="addAndPersistSpecies"
          />
        </div>

        <ul
          v-if="species.length"
          class="no-style-list panel content species-grid"
        >
          <li
            v-for="otu in sortedSpecies"
            :key="otu.id"
            class="d-flex middle gap-small padding-xsmall species-row"
          >
            <span
              class="button button-circle btn-delete"
              title="Delete permanently from key"
              @click="deleteChildLead(otu)"
            />
            <span
              v-html="otu.object_tag"
              class="ellipsis"
            />
          </li>
        </ul>
        <div
          v-else
          class="feedback feedback-info padding-small text-center"
        >
          No taxa in this key yet. Add OTUs above, or check
          <em>Add descendants on save</em> in the metadata block and save again.
        </div>
      </template>
    </BlockLayout>
</template>

<script setup>
import Autocomplete from '@/components/ui/Autocomplete.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import FormCitation from '@/components/Form/FormCitation.vue'
import NavBar from '@/components/layout/NavBar.vue'
import OtuPicker from '@/components/otu/otu_picker/otu_picker.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import Recent from './components/Recent.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import makeCitation from '@/factory/Citation'
import setParam from '@/helpers/setParam'
import { LEAD } from '@/constants/index.js'
import { URLParamsToJSON } from '@/helpers'
import { LinkerStorage } from '@/shared/Filter/utils'
import { RouteNames } from '@/routes/routes'
import { usePopstateListener } from '@/composables'
import { Citation, Lead, Otu, Source, Tag } from '@/routes/endpoints'
import { computed, onBeforeMount, ref, watch } from 'vue'

const DESCENDANTS_FILTERS = [
  { value: 'all', label: 'All descendants' },
  { value: 'valid', label: 'Only valid names' }
]

const emptyRoot = () => ({
  id: null,
  text: '',
  description: '',
  otu_id: null,
  is_public: false,
  is_virtual: false,
  global_id: null
})

const emptyCitation = () => ({
  ...makeCitation(LEAD),
  source_id: null,
  pages: null
})

const bootLoading = ref(false)
const root = ref(emptyRoot())
const parentOtu = ref(null)
const source = ref(null)
const citationData = ref(emptyCitation())
const species = ref([])
const childLeads = ref({})
const rootCitationId = ref(null)
const originalMetadata = ref(null)
const existingKeys = ref([])
const existingKeysLoading = ref(false)
const loading = ref(false)
const descendantsFilter = ref('valid')
const addDescendantsOnSave = ref(false)
const leadKeywords = ref([])
const tags = ref([])
const tagsBusy = ref(false)

const rootId = computed(() => root.value.id)
const rootGlobalId = computed(() => root.value.global_id)

const pages = computed({
  get: () => citationData.value.pages ?? '',
  set: (value) => {
    citationData.value.pages = value
  }
})

const isAddMode = computed(() => !!rootId.value)

const sortedSpecies = computed(() =>
  [...species.value].sort((a, b) => {
    const aName = stripHtml(a.taxon_name?.cached_html || a.object_tag || a.label_html || '')
    const bName = stripHtml(b.taxon_name?.cached_html || b.object_tag || b.label_html || '')
    return aName.localeCompare(bName)
  })
)

const publishedAfterMatches = computed(() => {
  const sourceDate = source.value?.cached_nomenclature_date
  if (!sourceDate) return []
  return species.value.filter((otu) => {
    const taxonDate = otu.taxon_name?.cached_nomenclature_date
    return taxonDate && taxonDate > sourceDate
  })
})

const misspellingMatches = computed(() =>
  species.value.filter((otu) => looksLikeMisspelling(otu.taxon_name))
)

const publishedAfterCount = computed(() => publishedAfterMatches.value.length)
const misspellingCount = computed(() => misspellingMatches.value.length)

const tagsByKeywordId = computed(() =>
  Object.fromEntries(tags.value.map((tag) => [tag.keyword_id, tag]))
)

const attachedTags = computed(() =>
  [...tags.value].sort((a, b) =>
    (a.keyword?.name ?? '').localeCompare(b.keyword?.name ?? '')
  )
)

const unattachedKeywords = computed(() =>
  leadKeywords.value.filter((k) => !tagsByKeywordId.value[k.id])
)

const isMetadataDirty = computed(() => {
  if (!isAddMode.value || !originalMetadata.value) return false
  return (
    root.value.text.trim() !== originalMetadata.value.text ||
    (root.value.description ?? '') !== originalMetadata.value.description ||
    root.value.otu_id !== originalMetadata.value.otu_id ||
    !!root.value.is_public !== originalMetadata.value.is_public ||
    (source.value?.id ?? null) !== originalMetadata.value.source_id ||
    pages.value !== originalMetadata.value.pages
  )
})

const canSave = computed(() => {
  if (loading.value) return false
  if (isAddMode.value) {
    return isMetadataDirty.value || addDescendantsOnSave.value
  }
  return (
    !!root.value.text.trim() &&
    !!parentOtu.value &&
    !!source.value
  )
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

function onSourceSelected(pickedSource) {
  if (pickedSource?.id) {
    setSourceMetadata(pickedSource)
  } else {
    source.value = null
  }
}

function hydrateSource(id) {
  return Source.find(id).then(({ body }) => {
    setSourceMetadata(body)
    citationData.value.source_id = body.id
  })
}

function setSourceMetadata(body) {
  source.value = {
    id: body.id,
    label_html: body.object_tag,
    object_tag: body.object_tag,
    cached_nomenclature_date: body.cached_nomenclature_date,
    year: body.year
  }
}

watch(() => citationData.value.source_id, (newId) => {
  if (!newId) {
    source.value = null
    existingKeys.value = []
  }
})

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
            updated_at: obj.updated_at,
            updated_at_in_words: obj.updated_at_in_words,
            updated_by: obj.updated_by,
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
      existingKeys.value = [...rootsMap.values()].sort((a, b) => {
        if (!a.updated_at && !b.updated_at) return 0
        if (!a.updated_at) return 1
        if (!b.updated_at) return -1
        return b.updated_at.localeCompare(a.updated_at)
      })
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

function addAndPersistSpecies(otu) {
  if (species.value.some((o) => o.id === otu.id)) return
  loading.value = true
  Promise.all([
    Lead.create({
      lead: {
        parent_id: root.value.id,
        otu_id: otu.id,
        text: null,
        is_virtual: true
      }
    }),
    Otu.find(otu.id, { extend: ['taxon_name'] })
  ])
    .then(([leadResponse, otuResponse]) => {
      const createdChild = leadResponse.body.lead
      species.value.push(otuResponse.body)
      childLeads.value = {
        ...childLeads.value,
        [otu.id]: {
          id: createdChild.id,
          global_id: createdChild.global_id
        }
      }
    })
    .catch(() => {})
    .finally(() => {
      loading.value = false
    })
}

function stripHtml(str) {
  if (str == null) return ''
  const el = document.createElement('div')
  el.innerHTML = String(str)
  return el.textContent ?? ''
}

function fetchDescendants() {
  if (!parentOtu.value?.taxon_name_id) return Promise.resolve()

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

  return Otu.where(params).then(({ body }) => {
    body.forEach((otu) => {
      if (otu.id === parentOtu.value.id) return
      addSpecies(otu)
    })
  })
}

function deleteAllChildren() {
  if (!species.value.length) return
  if (
    !window.confirm(
      `Permanently delete all ${species.value.length} taxa from this key?`
    )
  ) {
    return
  }

  loading.value = true
  const leadIds = species.value
    .map((otu) => childLeads.value[otu.id]?.id)
    .filter(Boolean)
  Promise.all(leadIds.map((id) => Lead.destroy(id)))
    .then(() => {
      species.value = []
      childLeads.value = {}
      TW.workbench.alert.create(
        `Deleted ${leadIds.length} taxa from the key.`,
        'notice'
      )
    })
    .catch(() => {})
    .finally(() => {
      loading.value = false
    })
}

function looksLikeMisspelling(taxonName) {
  if (!taxonName) return false
  if (taxonName.cached_misspelling) return true
  return /\[sic\]/i.test(taxonName.cached_html ?? '')
}

function removePublishedAfter() {
  destroyMatchingChildren(publishedAfterMatches.value, 'published after the key')
}

function removeMisspellings() {
  destroyMatchingChildren(misspellingMatches.value, 'misspellings')
}

function destroyMatchingChildren(matches, label) {
  if (!matches.length) return

  if (
    !window.confirm(
      `Permanently delete ${matches.length} ${label} from this key?`
    )
  ) {
    return
  }

  loading.value = true
  const deletions = matches
    .filter((otu) => !!childLeads.value[otu.id])
    .map((otu) => Lead.destroy(childLeads.value[otu.id].id).then(() => otu.id))
  Promise.all(deletions)
    .then((deletedOtuIds) => {
      const deletedIds = new Set(deletedOtuIds)
      species.value = species.value.filter((o) => !deletedIds.has(o.id))
      const leadMap = { ...childLeads.value }
      deletedOtuIds.forEach((id) => delete leadMap[id])
      childLeads.value = leadMap
      TW.workbench.alert.create(
        `Deleted ${deletedOtuIds.length} ${label}.`,
        'notice'
      )
    })
    .catch(() => {})
    .finally(() => {
      loading.value = false
    })
}

function reset() {
  root.value = emptyRoot()
  parentOtu.value = null
  source.value = null
  citationData.value = emptyCitation()
  species.value = []
  childLeads.value = {}
  rootCitationId.value = null
  originalMetadata.value = null
  existingKeys.value = []
  addDescendantsOnSave.value = false
  tags.value = []
  setParam(RouteNames.CiteKey, 'lead_id', null)
}

function loadLeadKeywords() {
  return Tag.all({ tag_object_type: 'Lead', per: 500 })
    .then(({ body }) => {
      const seen = new Map()
      body.forEach((tag) => {
        if (tag.keyword && !seen.has(tag.keyword.id)) {
          seen.set(tag.keyword.id, tag.keyword)
        }
      })
      leadKeywords.value = [...seen.values()].sort((a, b) =>
        (a.name ?? '').localeCompare(b.name ?? '')
      )
    })
    .catch(() => {})
}

function loadTagsForRoot(rootLeadId) {
  return Tag.all({
    tag_object_type: 'Lead',
    tag_object_id: rootLeadId,
    per: 100
  })
    .then(({ body }) => {
      tags.value = body
    })
    .catch(() => {
      tags.value = []
    })
}

function keywordPillStyle(keyword) {
  const c = keyword?.css_color
  if (!c) return null
  return {
    backgroundColor: c,
    color: c
  }
}

function keywordOutlineStyle(keyword) {
  const c = keyword?.css_color
  if (!c) return null
  return {
    backgroundColor: `color-mix(in srgb, ${c} 18%, transparent)`,
    color: c,
    borderColor: c
  }
}

function attachKeyword(keyword) {
  if (!root.value.id || tagsByKeywordId.value[keyword.id]) return
  tagsBusy.value = true
  Tag.create({
    tag: {
      keyword_id: keyword.id,
      tag_object_type: 'Lead',
      tag_object_id: root.value.id
    }
  })
    .then(({ body }) => {
      const created = body.keyword ? body : { ...body, keyword }
      tags.value = [...tags.value, created]
    })
    .catch(() => {})
    .finally(() => {
      tagsBusy.value = false
    })
}

function removeTag(tag) {
  tagsBusy.value = true
  Tag.destroy(tag.id)
    .then(() => {
      tags.value = tags.value.filter((t) => t.id !== tag.id)
    })
    .catch(() => {})
    .finally(() => {
      tagsBusy.value = false
    })
}

function captureMetadataBaseline() {
  originalMetadata.value = {
    text: root.value.text.trim(),
    description: root.value.description ?? '',
    otu_id: root.value.otu_id,
    is_public: !!root.value.is_public,
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
        description: loadedRoot.description ?? '',
        otu_id: loadedRoot.otu_id,
        is_public: !!loadedRoot.is_public,
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

      return Promise.all([
        Citation.all({
          citation_object_type: 'Lead',
          citation_object_id: loadedRoot.id,
          extend: ['source'],
          per: 10
        }).then(({ body: citations }) => {
          const rootCitation = citations[0]
          if (rootCitation) {
            rootCitationId.value = rootCitation.id
            citationData.value = {
              ...emptyCitation(),
              id: rootCitation.id,
              source_id: rootCitation.source?.id ?? null,
              pages: rootCitation.pages ?? null
            }
            if (rootCitation.source) {
              return hydrateSource(rootCitation.source.id)
            }
          } else {
            citationData.value = emptyCitation()
          }
        }),
        loadTagsForRoot(loadedRoot.id)
      ])
    })
    .then(() => {
      setParam(RouteNames.CiteKey, 'lead_id', rootLeadId)
      captureMetadataBaseline()
    })
    .catch((err) => {
      if (err?.message !== 'redirect') {
        TW.workbench.alert.create('Failed to load simple key.', 'error')
      }
    })
    .finally(() => {
      loading.value = false
    })
}

function save() {
  loading.value = true
  const prep = addDescendantsOnSave.value
    ? fetchDescendants()
    : Promise.resolve()

  prep
    .then(() => {
      addDescendantsOnSave.value = false
      return isAddMode.value ? saveChangesToLoadedKey() : createNewKey()
    })
    .catch(() => {})
    .finally(() => {
      loading.value = false
    })
}

function saveChangesToLoadedKey() {
  const tasks = []

  if (isMetadataDirty.value) {
    tasks.push(persistMetadataChanges())
  }

  const unpersisted = species.value.filter((o) => !childLeads.value[o.id])
  if (unpersisted.length) {
    tasks.push(persistNewTaxa(unpersisted))
  }

  return Promise.all(tasks)
    .then((results) => {
      const messages = results.filter(Boolean)
      if (messages.length) {
        TW.workbench.alert.create(messages.join(' '), 'notice')
      }
      return loadKey(root.value.id)
    })
    .catch(() => {})
}

function persistMetadataChanges() {
  const leadUpdate = Lead.update(root.value.id, {
    lead: {
      text: root.value.text.trim(),
      description: (root.value.description ?? '').trim() || null,
      otu_id: root.value.otu_id,
      is_public: !!root.value.is_public,
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

function persistNewTaxa(toAdd) {
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
  const rootPayload = {
    lead: {
      text: root.value.text.trim(),
      description: (root.value.description ?? '').trim() || null,
      otu_id: root.value.otu_id,
      is_public: !!root.value.is_public,
      is_virtual: true
    }
  }

  return Lead.create(rootPayload)
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
  loadLeadKeywords()

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
      const parentNote = body.parent_otu
        ? 'parent inferred as ' + stripHtml(body.parent_otu.object_tag)
        : 'no shared parent inferred'
      const truncationNote = body.truncated
        ? ` Only the first ${body.otus.length} of ${body.total} filtered taxa were loaded.`
        : ''
      TW.workbench.alert.create(
        `Prefilled ${body.otus.length} taxa from Filter OTUs; ` +
          parentNote +
          '. Pick a source and title, then save the simple key.' +
          truncationNote,
        'notice'
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

.tag-remove {
  margin-left: 0.25em;
  font-weight: bold;
}

.keyword-clickable {
  cursor: pointer;
  user-select: none;
}

.keyword-clickable:hover {
  opacity: 0.85;
}

.keyword-outline {
  background-color: color-mix(in srgb, #b3b3b3 18%, transparent);
  border: 1px solid currentColor;
  color: #6b6b6b;
}

.keyword-outline > span {
  color: inherit;
  filter: none;
}

</style>

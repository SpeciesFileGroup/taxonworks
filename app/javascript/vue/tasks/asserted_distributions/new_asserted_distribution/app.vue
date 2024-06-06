<template>
  <div id="vue-task-asserted-distribution-new">
    <VSpinner
      v-if="isLoading"
      full-screen
      :logo-size="{ width: '100px', height: '100px' }"
      legend="Loading..."
    />
    <h1>Task - New asserted distribution</h1>
    <NavBar class="margin-medium-bottom">
      <div class="flex-separate middle">
        <div>
          <span
            v-if="currentAssertedDistribution"
            v-html="currentAssertedDistribution.object_tag"
          />
          <span v-else>New record</span>
        </div>
        <div class="horizontal-center-content middle">
          <label class="middle margin-small-right">
            <input
              v-model="autosave"
              type="checkbox"
            />
            Autosave
          </label>
          <button
            type="button"
            :disabled="!validate"
            class="button normal-input button-submit separate-left separate-right"
            @click="saveAssertedDistribution"
          >
            {{ asserted_distribution.id ? 'Update' : 'Create' }}
          </button>
          <button
            type="button"
            class="button normal-input button-default padding-medium-left padding-medium-right"
            @click="newWithLock"
          >
            New
          </button>
        </div>
      </div>
    </NavBar>
    <div class="horizontal-left-content align-start">
      <div class="width-30">
        <div
          class="horizontal-left-content panel-section separate-right align-start"
        >
          <FormCitation
            class="full_width"
            ref="formCitationRef"
            v-model="asserted_distribution.citation"
            v-model:absent="asserted_distribution.is_absent"
            :klass="ASSERTED_DISTRIBUTION"
            :target="ASSERTED_DISTRIBUTION"
            lock-button
            absent-field
            @lock="locks.citation = $event"
          />
        </div>
        <div class="horizontal-left-content">
          <ul class="no_bullets context-menu">
            <li class="navigation-item context-menu-option">
              <a :href="RouteNames.NewSource">New source</a>
            </li>
          </ul>
        </div>
      </div>
      <div
        class="horizontal-left-content separate-bottom separate-left separate-right align-start width-40"
      >
        <OtuComponent
          class="separate-right full_width"
          v-model="asserted_distribution.otu"
          v-model:lock="locks.otu"
        />
      </div>
      <div class="horizontal-left-content separate-left align-start width-30">
        <GeographicArea
          class="separate-right full_width"
          v-model="asserted_distribution.geographicArea"
          v-model:lock="locks.geographicArea"
          @selected="triggerAutosave"
        />
      </div>
    </div>

    <TableComponent
      class="full_width"
      :list="list"
      @on-source-otu="setSourceOtu"
      @on-source-geo="setSourceGeo"
      @on-otu-geo="setGeoOtu"
      @remove="removeAssertedDistribution"
    />
  </div>
</template>

<script setup>
import OtuComponent from './components/otu'
import GeographicArea from './components/geographicArea'
import TableComponent from './components/table'
import VSpinner from '@/components/ui/VSpinner'
import NavBar from '@/components/layout/NavBar'
import platformKey from '@/helpers/getPlatformKey'
import FormCitation from '@/components/Form/FormCitation.vue'
import useHotkey from 'vue3-hotkey'
import { smartSelectorRefresh } from '@/helpers/smartSelector/index.js'
import { ASSERTED_DISTRIBUTION } from '@/constants/index.js'
import { RouteNames } from '@/routes/routes.js'
import { Source, AssertedDistribution } from '@/routes/endpoints'
import { computed, ref, reactive, onMounted } from 'vue'
import { addToArray, removeFromArray } from '@/helpers'

const extend = ['citations', 'geographic_area', 'otu', 'source']

defineOptions({
  name: 'NewAssertedDistribution'
})

const shortcuts = ref([
  {
    keys: [platformKey(), 's'],
    handler() {
      saveAssertedDistribution()
    }
  }
])

useHotkey(shortcuts.value)

const asserted_distribution = ref(newAssertedDistribution())
const list = ref([])
const isLoading = ref(true)
const autosave = ref(true)
const formCitationRef = ref(null)

const locks = reactive({
  otu: false,
  geographicArea: false,
  citation: false
})

const validate = computed(
  () =>
    asserted_distribution.value.otu &&
    asserted_distribution.value.geographicArea &&
    asserted_distribution.value.citation.source_id
)

const currentAssertedDistribution = computed(() =>
  list.value.find((item) => item.id === asserted_distribution.value.id)
)

onMounted(() => {
  AssertedDistribution.where({ recent: true, per: 15, extend }).then(
    ({ body }) => {
      list.value = body
      isLoading.value = false
    }
  )
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+s`,
    'Save and create new asserted distribution',
    'New asserted distribution'
  )
})

function triggerAutosave() {
  if (validate.value && autosave.value) {
    saveAssertedDistribution()
  }
}

function newAssertedDistribution() {
  return {
    id: undefined,
    otu: undefined,
    geographicArea: undefined,
    is_absent: undefined,
    citation: {
      id: undefined,
      source: undefined,
      pages: undefined,
      is_original: undefined
    }
  }
}

function newWithLock() {
  const newObject = newAssertedDistribution()
  const keys = Object.keys(newObject)

  keys.forEach((key) => {
    if (locks[key]) {
      newObject[key] = asserted_distribution.value[key]
    }
  })

  asserted_distribution.value = newObject
}

function makeAssertedDistributionPayload(data) {
  return {
    id: data.id,
    otu_id: data.otu.id,
    geographic_area_id: data.geographicArea.id,
    is_absent: data.is_absent,
    citations_attributes: [
      {
        id: data.citation.id,
        source_id: data.citation.source_id,
        is_original: data.citation.is_original,
        pages: data.citation.pages
      }
    ]
  }
}

function saveAssertedDistribution() {
  if (!validate.value) return
  const assertedDistribution = makeAssertedDistributionPayload(
    asserted_distribution.value
  )

  if (assertedDistribution.id) {
    saveRecord(assertedDistribution)
  } else {
    assertedDistribution.citations_attributes[0].id = undefined
    AssertedDistribution.where({
      otu_id: assertedDistribution.otu_id,
      geographic_area_id: assertedDistribution.geographic_area_id,
      extend
    }).then(({ body }) => {
      const record = body.find(
        (item) => !!item.is_absent === !!assertedDistribution.is_absent
      )

      if (record) {
        assertedDistribution.id = record.id
        saveRecord(assertedDistribution)
      } else {
        saveRecord(assertedDistribution)
      }
    })
  }
}

function saveRecord(assertedDistribution) {
  const payload = {
    asserted_distribution: assertedDistribution,
    extend
  }

  const request = assertedDistribution.id
    ? AssertedDistribution.update(assertedDistribution.id, payload)
    : AssertedDistribution.create(payload)

  request
    .then(({ body }) => {
      addToArray(list.value, body, { prepend: true })
      TW.workbench.alert.create(
        'Asserted distribution was successfully saved.',
        'notice'
      )
      smartSelectorRefresh()
      newWithLock()
    })
    .catch(() => {})
}

function removeAssertedDistribution(asserted) {
  AssertedDistribution.destroy(asserted.id).then(() => {
    removeFromArray(list.value, asserted)
  })
}

function setSourceOtu(item) {
  newWithLock()
  setCitation(item.citations[0])
  asserted_distribution.value.id = undefined
  asserted_distribution.value.otu = item.otu
}

function setSourceGeo(item) {
  newWithLock()
  setCitation(item.citations[0])
  asserted_distribution.value.geographicArea = item.geographic_area
  asserted_distribution.value.is_absent = item.is_absent
}

function setGeoOtu(item) {
  newWithLock()
  autosave.value = false
  asserted_distribution.value.id = item.id
  asserted_distribution.value.geographicArea = item.geographic_area
  asserted_distribution.value.otu = item.otu
  asserted_distribution.value.is_absent = item.is_absent
}

function setCitation(citation) {
  Source.find(citation.source_id).then(({ body }) => {
    asserted_distribution.value.citation = {
      id: undefined,
      source: body,
      source_id: citation.source_id,
      is_original: citation.is_original,
      pages: citation.pages
    }
  })
}
</script>

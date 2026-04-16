<template>
  <div>
    <h1>Match collection objects</h1>
    <VSpinner
      v-if="isLoading"
      full-screen
    />
    <div class="flex-row align-start gap-medium">
      <div class="flex-col gap-medium left-column">
        <div class="panel">
          <div class="flex-row flex-separate middle content gap-small">
            <VBtn
              color="primary"
              medium
              :disabled="!params.match_identifiers"
              @click="getMatchList"
            >
              Match
            </VBtn>
            <VBtn
              circle
              color="primary"
              @click="reset"
            >
              <VIcon
                x-small
                name="reset"
              />
            </VBtn>
          </div>
        </div>
        <FacetMatchIdentifiers
          :rows="10"
          v-model="params"
        />
      </div>
      <div class="full_width">
        <VNavbar>
          <div class="flex-separate full_width">
            <ul class="no_bullets context-menu">
              <li
                v-for="(value, key) in sectionTitles"
                :key="key"
              >
                <label>
                  <input
                    type="radio"
                    :value="key"
                    v-model="tableView"
                  />
                  {{ value }}
                </label>
              </li>
            </ul>
            <div class="flex-row gap-large">
              <div class="horizontal-left-content">
                <span class="margin-small-right">Matches</span>
                <div class="square-brackets">
                  <ul class="no_bullets context-menu">
                    <li>
                      <RadialFilter
                        :disabled="!listMatched.length"
                        :parameters="params"
                        :object-type="COLLECTION_OBJECT"
                        :extended-slices="EXTENDED_SLICES"
                      />
                    </li>
                    <li>
                      <RadialMass
                        :disabled="!listMatched.length"
                        :parameters="params"
                        :object-type="COLLECTION_OBJECT"
                        nested-query
                      />
                    </li>
                    <li>
                      <RadialCollectionObject
                        :disabled="!listMatched.length"
                        :parameters="params"
                        :list="listMatched"
                      />
                    </li>
                    <li>
                      <RadialLoan
                        :disabled="!listMatched.length"
                        :parameters="params"
                        :object-type="COLLECTION_OBJECT"
                      />
                    </li>
                  </ul>
                </div>
              </div>

              <div class="horizontal-left-content">
                <span class="margin-small-right">Selected</span>
                <div class="square-brackets">
                  <ul class="no_bullets context-menu">
                    <li>
                      <VCompare
                        :compare="
                          listMatched
                            .filter(({ item }) => selectedIds.includes(item.id))
                            .map(({ item }) => item)
                        "
                      />
                    </li>
                    <li>
                      <RadialFilter
                        :disabled="!selectedIds.length"
                        :ids="selectedIds"
                        :object-type="COLLECTION_OBJECT"
                        :extended-slices="EXTENDED_SLICES"
                      />
                    </li>
                    <li>
                      <RadialMass
                        :disabled="!selectedIds.length"
                        :ids="selectedIds"
                        :object-type="COLLECTION_OBJECT"
                      />
                    </li>
                    <li>
                      <RadialCollectionObject
                        :disabled="!selectedIds.length"
                        :ids="selectedIds"
                        :list="listMatched"
                      />
                    </li>
                    <li>
                      <RadialLoan
                        :disabled="!selectedIds.length"
                        :ids="selectedIds"
                        :object-type="COLLECTION_OBJECT"
                      />
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </VNavbar>
        <TableUnmatched
          v-if="
            tableView === TABLE_COMPONENT.Unmatched ||
            tableView === TABLE_COMPONENT.Both
          "
          :list="listUnmatched"
          class="full_width margin-medium-bottom"
        />
        <TableMatched
          v-if="
            tableView === TABLE_COMPONENT.Matches ||
            tableView === TABLE_COMPONENT.Both
          "
          :list="listMatched"
          v-model="selectedIds"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { CollectionObject } from '@/routes/endpoints'
import { URLParamsToJSON } from '@/helpers/url/parse'
import { computed, ref, onBeforeMount } from 'vue'
import VCompare from './components/VCompare.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VNavbar from '@/components/layout/NavBar.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import TableMatched from './components/Table/TableMatched.vue'
import TableUnmatched from './components/Table/TableUnmatched.vue'
import FacetMatchIdentifiers from '@/components/Filter/Facets/shared/FacetMatchIdentifiers.vue'
import RadialFilter from '@/components/radials/filter/radial.vue'
import RadialMass from '@/components/radials/mass/radial.vue'
import RadialCollectionObject from '@/components/radials/co/radial.vue'
import RadialLoan from '@/components/radials/loan/radial.vue'
import { COLLECTION_OBJECT } from '@/constants'
import { FILTER_COLLECTION_OBJECT } from '@/components/radials/filter/constants/filterLinks'

defineOptions({
  name: 'CollectionObjectMatch'
})

const EXTENDED_SLICES = [
  {
    ...FILTER_COLLECTION_OBJECT,
    flattenQuery: true
  }
]

const TABLE_COMPONENT = {
  Matches: 'Matches',
  Unmatched: 'Unmatched',
  Both: 'Both'
}

const params = ref({})
const isLoading = ref(false)
const selectedIds = ref([])
const list = ref([])
const tableView = ref(TABLE_COMPONENT.Both)

const listUnmatched = computed(() => list.value.filter(({ item }) => !item))
const listMatched = computed(() => list.value.filter(({ item }) => item))

const sectionTitles = computed(() => {
  const matchesCount = listMatched.value.length
  const unmatchedCount = listUnmatched.value.length
  const bothCount = matchesCount + unmatchedCount

  return {
    [TABLE_COMPONENT.Matches]: `Matches (${matchesCount})`,
    [TABLE_COMPONENT.Unmatched]: `Unmatched (${unmatchedCount})`,
    [TABLE_COMPONENT.Both]: `Both (${bothCount})`
  }
})

function reset() {
  params.value = {}
  list.value = []
  selectedIds.value = []
}

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)
  const coIds = [].concat(urlParams.collection_object_id || [])
  const identifierIds = [].concat(urlParams.identifier_id || [])

  const hasCoIds = coIds.length > 0
  const hasIdentifierIds = identifierIds.length > 0

  if (hasCoIds || hasIdentifierIds) {
    const ids = hasCoIds ? coIds : identifierIds
    const type = hasCoIds ? 'internal' : 'identifier'

    Object.assign(params.value, {
      match_identifiers: ids.join('\n'),
      match_identifiers_type: type,
      match_identifiers_delimiter: '\n'
    })

    getMatchList()
  } else if (Object.keys(urlParams).length) {
    getListByParamters({ ...urlParams })
  }
})

function getListByParamters() {
  CollectionObject.filter({
    ...params.value,
    per: 1000,
    extend: ['identifiers']
  }).then(({ body }) => {
    list.value = Object.fromEntries(body.map((item) => [item.id, item]))
  })
}

async function getMatchList() {
  const identifiers = params.value.match_identifiers
    .split(params.value.match_identifiers_delimiter)
    .filter((i) => i.trim().length)

  list.value = []

  isLoading.value = true

  try {
    const { body } = await CollectionObject.filter({
      ...params.value,
      per: 1000,
      extend: ['identifiers']
    })

    const getValue = getMatchByFunction(params.value.match_identifiers_type)

    list.value = identifiers.map((identifier) => ({
      identifier,
      item: body.find((item) => getValue(item, identifier))
    }))
  } catch {
  } finally {
    isLoading.value = false
  }
}

function getMatchByFunction(type) {
  return type == 'internal'
    ? (item, identifier) => item.id == Number(identifier)
    : (item, identifier) =>
        item.identifiers.find((item) => item.cached.includes(identifier))
}
</script>

<style scoped>
.left-column {
  width: 400px;
}
</style>

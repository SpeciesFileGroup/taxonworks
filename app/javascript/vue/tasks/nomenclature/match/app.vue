<template>
  <div>
    <h1>Match taxon names</h1>
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
              :disabled="!lines.length"
              @click="GetMatches"
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
        <input-component
          v-model:names="names"
          v-model="params"
          @lines="lines = $event"
        />
        <FacetValidity v-model="params" />
      </div>
      <div class="full_width">
        <VNavbar>
          <div class="flex-separate full_width">
            <ul class="no_bullets context-menu">
              <li
                v-for="(value, key) in tableComponent"
                :key="key"
              >
                <label>
                  <input
                    type="radio"
                    :value="value"
                    v-model="tableView"
                  />
                  {{ sectionTitles[key] }}
                </label>
              </li>
            </ul>
            <div class="horizontal-left-content">
              <span class="margin-small-right">Matches</span>
              <div class="square-brackets">
                <ul class="no_bullets context-menu">
                  <li>
                    <RadialFilter
                      :disabled="!matchedIds.length"
                      :ids="matchedIds"
                      :object-type="TAXON_NAME"
                      :extended-slices="EXTENDED_SLICES"
                    />
                  </li>
                  <li>
                    <CSVButton
                      :list="matches"
                      :options="{ fields }"
                    />
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </VNavbar>

        <TableUnmatched
          v-if="
            tableView === tableComponent.Unmatched ||
            tableView === tableComponent.Both
          "
          :list="unmatched"
          class="full_width margin-medium-bottom"
        />
        <TableMatched
          v-if="
            tableView === tableComponent.Matches ||
            tableView === tableComponent.Both
          "
          :list="validTaxonNames"
          class="full_width"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { TaxonName } from '@/routes/endpoints'
import { getUnique } from '@/helpers/arrays'
import { TAXON_NAME } from '@/constants'
import { FILTER_TAXON_NAME } from '@/components/radials/filter/constants/filterLinks'
import TableMatched from './components/Table/TableMatched.vue'
import TableUnmatched from './components/Table/TableUnmatched.vue'
import InputComponent from './components/InputComponent.vue'
import VSpinner from '@/components/ui/VSpinner'
import VNavbar from '@/components/layout/NavBar'
import CSVButton from '@/components/csvButton.vue'
import FacetValidity from '../filter/components/filters/FacetValidity.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import RadialFilter from '@/components/radials/filter/radial.vue'

const EXTENDED_SLICES = [
  {
    ...FILTER_TAXON_NAME,
    flattenQuery: true
  }
]

const fields = [
  { label: 'Id', value: 'taxon.id' },
  { label: 'taxon name', value: 'taxon.object_label' },
  { label: 'Author and year', value: 'taxon.cached_author_year' },
  { label: 'Valid name', value: 'taxon.original_combination' }
]

const tableComponent = {
  Matches: 'Matches',
  Unmatched: 'Unmatched',
  Both: 'Both'
}

const isLoading = ref(false)
const matches = ref([])
const names = ref('')
const params = ref({})
const tableView = ref(tableComponent.Both)
const unmatched = ref([])
const validTaxonNames = ref({})

const sectionTitles = computed(() => ({
  Matches: `Matches (${matches.value.length})`,
  Unmatched: `Unmatched (${unmatched.value.length})`,
  Both: `Both (${matches.value.length + unmatched.value.length})`
}))

function reset() {
  matches.value = []
  names.value = ''
  params.value = {}
  unmatched.value = []
  validTaxonNames.value = {}
}

const matchedIds = computed(() => matches.value.map((m) => m.taxon.id))
const lines = computed(() =>
  names.value.split('\n').filter((line) => line.trim().length)
)

function GetMatches() {
  const lineRequests = {}
  const requests = lines.value.map((line) => {
    const request = TaxonName.where({
      name: line,
      ...params.value
    })

    request.then((response) => {
      lineRequests[line] = response.body
    })

    return request
  })

  validTaxonNames.value = {}

  isLoading.value = true
  Promise.all(requests)
    .then(async (responses) => {
      const taxonNames = [].concat(...responses.map((r) => r.body))
      const uniqueList = getUnique(taxonNames, 'id')
      const validTaxonNameIDs = uniqueList.map(
        (taxon) => taxon.cached_valid_taxon_name_id
      )

      const validNames = validTaxonNameIDs.length
        ? (
            await TaxonName.all({
              taxon_name_id: [...new Set(validTaxonNameIDs)]
            })
          ).body
        : []

      validNames.forEach((taxon) => {
        const taxonList = getUnique(
          Object.values(lineRequests)
            .flat()
            .filter((item) => item.cached_valid_taxon_name_id === taxon.id),
          'id'
        )

        const lines = Object.entries(lineRequests)
          .filter(([_, taxones]) =>
            taxones.find((item) => item.cached_valid_taxon_name_id === taxon.id)
          )
          .map(([key, _]) => key)

        validTaxonNames.value[taxon.id] = {
          lines,
          taxon: taxonList,
          validTaxon: taxon
        }
      })

      matches.value = uniqueList.map((taxon) => {
        return {
          taxon,
          match: Object.keys(lineRequests).filter((key) =>
            lineRequests[key].some((item) => item.id === taxon.id)
          )
        }
      })

      unmatched.value = matches.value.length
        ? lines.value.filter(
            (line) => !matches.value.some(({ match }) => match.includes(line))
          )
        : lines.value

      tableView.value = tableComponent.Both
    })
    .finally(() => {
      isLoading.value = false
    })
}
</script>

<style scoped>
.left-column {
  width: 400px;
}
</style>

<template>
  <div>
    <h1>Match taxon names</h1>
    <spinner-component
      v-if="isLoading"
      full-screen
    />
    <input-component @lines="lines = $event" />
    <div class="horizontal-left-content margin-medium-bottom margin-small-top">
      <button
        class="button normal-input button-default margin-small-right"
        type="button"
        :disabled="!lines.length"
        @click="GetMatches"
      >
        Match
      </button>
      <label class="middle">
        <input
          type="checkbox"
          v-model="exact"
        />
        Exact match
      </label>

      <Validity v-model="valid" />
    </div>

    <navbar-component>
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
              {{ value }}
            </label>
          </li>
        </ul>
        <CSVButton
          :list="matches"
          :options="{ fields }"
        />
      </div>
    </navbar-component>

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
</template>

<script setup>
import { ref } from 'vue'
import { TaxonName } from '@/routes/endpoints'
import { getUnique } from '@/helpers/arrays'
import TableMatched from './components/Table/TableMatched.vue'
import TableUnmatched from './components/Table/TableUnmatched.vue'
import InputComponent from './components/InputComponent.vue'
import SpinnerComponent from '@/components/ui/VSpinner'
import NavbarComponent from '@/components/layout/NavBar'
import CSVButton from '@/components/csvButton.vue'
import Validity from './components/Validity.vue'

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

const exact = ref(false)
const matches = ref([])
const unmatched = ref([])
const isLoading = ref(false)
const lines = ref([])
const tableView = ref(tableComponent.Both)
const validTaxonNames = ref({})
const valid = ref(undefined)

function GetMatches() {
  const lineRequests = {}
  const requests = lines.value.map((line) => {
    const request = TaxonName.where({
      name: line,
      name_exact: exact.value,
      validity: valid.value
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

<template>
  <div>
    <h1>Nomenclature match</h1>
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
        >
        Exact match
      </label>
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
              >
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
      v-if="(tableView === tableComponent.Unmatched || tableView === tableComponent.Both)"
      :list="unmatched"
      class="full_width margin-medium-bottom"
    />
    <TableMatched
      v-if="(tableView === tableComponent.Matches || tableView === tableComponent.Both)"
      :list="matches"
      class="full_width"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { TaxonName } from 'routes/endpoints'
import { getUnique } from 'helpers/arrays'
import TableMatched from './components/Table/TableMatched.vue'
import TableUnmatched from './components/Table/TableUnmatched.vue'
import InputComponent from './components/InputComponent.vue'
import SpinnerComponent from 'components/spinner'
import NavbarComponent from 'components/layout/NavBar'
import CSVButton from 'components/csvButton.vue'

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

function GetMatches () {
  const requests = lines.value.map(name => TaxonName.where({ name, exact: exact.value }))

  isLoading.value = true
  Promise.all(requests).then(responses => {
    const taxonNames = [].concat(...responses.map(r => r.body))
    const uniqueList = getUnique(taxonNames, 'id')

    matches.value = uniqueList.map(taxon =>
      ({
        taxon,
        match: lines.value.filter(line => taxon.object_label.toLowerCase().includes(line.toLowerCase())).join(', ')
      })
    )

    unmatched.value = lines.value.filter(
      line => !matches.value.length || !!matches.value.find(({ match }) => !match.includes(line))
    )

    tableView.value = tableComponent.Both
  })
    .finally(() => {
      isLoading.value = false
    })
}

</script>

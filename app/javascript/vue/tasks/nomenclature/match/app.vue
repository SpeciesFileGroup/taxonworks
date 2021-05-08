<template>
  <div>
    <h1>Nomenclature match</h1>
    <spinner-component
      v-if="isLoading"
      :full-screen="true"/>
    <div class="horizontal-left-content align-start">
      <div class="full_width margin-small-right">
        <input-component @lines="lines = $event"/>
        <div class="flex-separate">
          <button
            class="button normal-input button-default"
            type="button"
            :disabled="!lines.length"
            @click="processList">
            Match
          </button>
          <label>
          <input
            type="checkbox"
            v-model="exact">
            Exact match
          </label>
        </div>
      </div>

      <div class="full_width margin-small-left">
        <navbar-component>
          <ul class="no_bullets context-menu">
            <li
              class="capitalize"
              v-for="item in show">
              <label>
                <input
                  type="radio"
                  :value="item"
                  v-model="filter">
                  {{ item }}
              </label>
            </li>
          </ul>
        </navbar-component>
        <template v-for="(match, key) in matches">
          <line-component
            v-if="filterView(match)"
            class="margin-small-bottom"
            :key="key"
            :name="key"
            :records="match"/>
        </template>
      </div>
    </div>
  </div>
</template>

<script>

import InputComponent from './components/InputComponent'
import LineComponent from './components/LineComponent'
import SpinnerComponent from 'components/spinner'
import NavbarComponent from 'components/navBar'
import { TaxonName } from 'routes/endpoints'

export default {
  components: {
    InputComponent,
    LineComponent,
    SpinnerComponent,
    NavbarComponent
  },
  data () {
    return {
      lines: [],
      maxPerCall: 1,
      exact: false,
      isLoading: false,
      show: ['matches', 'unmatched', 'both'],
      filter: 'both',
      matches: {}
    }
  },
  methods: {
    GetMatches (position) {
      const promises = []

      for (let i = 0; i < this.maxPerCall; i++) {
        if (position < this.lines.length) {
          promises.push(new Promise((resolve, reject) => {
            const name = this.lines[position]
            TaxonName.where({ name: name, exact: this.exact }).then(response => {
              this.$set(this.matches, name, response.body)
              resolve()
            })
          }))
          position++
        }
      }
      Promise.all(promises).then(() => {
        if (position < this.lines.length) {
          this.GetMatches(position)
        } else {
          this.isLoading = false
        }
      })
    },
    processList () {
      this.matches = {}
      this.isLoading = true
      this.GetMatches(0)
    },
    filterView (record) {
      switch (this.filter) {
        case 'matches':
          return record.length
        case 'unmatched':
          return !record.length
        default:
          return true
      }
    }
  }
}
</script>

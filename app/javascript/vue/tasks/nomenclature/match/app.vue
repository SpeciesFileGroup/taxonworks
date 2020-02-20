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
        <line-component
          class="margin-small-bottom"
          v-for="(match, key) in matches"
          :name="key"
          :records="match"/>
      </div>
    </div>
  </div>
</template>

<script>

import InputComponent from './components/InputComponent'
import LineComponent from './components/LineComponent'
import { GetTaxonName } from './request/resources'
import SpinnerComponent from 'components/spinner'

export default {
  components: {
    InputComponent,
    LineComponent,
    SpinnerComponent
  },
  data () {
    return {
      lines: [],
      maxPerCall: 1,
      exact: false,
      isLoading: false,
      matches: {}
    }
  },
  methods: {
    GetMatches (position) {
        let promises = []

        for(let i = 0; i < this.maxPerCall; i++) {
          if(position < this.lines.length) {
            promises.push(new Promise((resolve, reject) => {
              let name = this.lines[position]
              GetTaxonName(name, this.exact).then(response => {
                this.$set(this.matches, name, response.body)
                resolve()
              })
            }))
            position++
          }
          
        }
        Promise.all(promises).then(response => {
          if(position < this.lines.length)
            this.GetMatches(position)
          else {
            this.isLoading = false
          }
        })
    },
    processList () {
      this.matches = {}
      this.isLoading = true
      this.GetMatches(0)
    }
  }
}
</script>
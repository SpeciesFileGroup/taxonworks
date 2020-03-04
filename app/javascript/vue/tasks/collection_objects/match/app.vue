<template>
  <div>
    <h1>Collection object match</h1>
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
          <ul class="no_bullets context-menu">
            <li v-for="option in searchParams">
              <label>
                <input
                  v-model="paramSelected"
                  :value="option.value"
                  type="radio">
                  {{ option.label }}
              </label>
            </li>
          </ul>
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
        <line-component
          v-if="filterView(match)"
          class="margin-small-bottom"
          v-for="(match, key) in matches"
          :value="key"
          :records="match"/>
      </div>
    </div>
  </div>
</template>

<script>

import InputComponent from './components/InputComponent'
import LineComponent from './components/LineComponent'
import { GetCollectionObject, GetCollectionObjectById } from './request/resources'
import SpinnerComponent from 'components/spinner'
import NavbarComponent from 'components/navBar'

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
      matches: {},
      searchParams: [
        {
          label: 'By ID',
          value: undefined
        },
        {
          label: 'Identifier exact',
          value: 'identifier_exact'
        }
      ],
      paramSelected: undefined
    }
  },
  methods: {
    GetMatches (position) {
        let promises = []

        for(let i = 0; i < this.maxPerCall; i++) {
          if(position < this.lines.length) {
            promises.push(new Promise((resolve, reject) => {
              let value = this.lines[position]
              if(this.paramSelected) {
                GetCollectionObject({ [this.paramSelected]: true, identifier: value }).then(response => {
                  this.$set(this.matches, value, response.body)
                  resolve()
                }, () => {
                  this.$set(this.matches, value, {})
                  reject()
                })
              } else {
                if(!Number(value)) return reject()
                  GetCollectionObjectById(value).then(response => {
                    this.$set(this.matches, value, response.body)
                    resolve()
                  }, () => {
                    this.$set(this.matches, value, {})
                    reject()
                  })
              }
            }).catch(e => {}))
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
    },
    filterView (record) {
      switch(this.filter) {
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

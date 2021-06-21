<template>
  <div>
    <h1>Collection object match</h1>
    <spinner-component
      v-if="isLoading"
      :full-screen="true"/>
    <div class="horizontal-left-content align-start">
      <div class="full_width margin-small-right">
        <input-component @lines="lines = $event"/>
        <div class="flex-separate margin-medium-bottom">
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
        <assign-component
          :ids="ids"/>
      </div>
      <div class="full_width margin-small-left">
        <line-component
          @selected="ids = $event"
          class="margin-small-bottom"
          :match-list="matches"/>
      </div>
    </div>
  </div>
</template>

<script>

import InputComponent from './components/InputComponent'
import LineComponent from './components/LineComponent'
import AssignComponent from './components/AssignComponent'
import SpinnerComponent from 'components/spinner'
import { CollectionObject } from 'routes/endpoints'
import {
  GetCollectionObject,
  GetCollectionObjectById
} from './request/resources'

export default {
  components: {
    InputComponent,
    LineComponent,
    AssignComponent,
    SpinnerComponent
  },
  data () {
    return {
      lines: [],
      ids: [],
      maxPerCall: 1,
      exact: false,
      isLoading: false,
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
      const promises = []

      for (let i = 0; i < this.maxPerCall; i++) {
        if (position < this.lines.length) {
          promises.push(new Promise((resolve, reject) => {
            const value = this.lines[position]
            if (this.paramSelected) {
              CollectionObject.where({ [this.paramSelected]: true, identifier: value }).then(response => {
                this.matches[value] = response.body
                resolve()
              }, () => {
                this.matches[value] = {}
                reject()
              })
            } else {
              if(!Number(value)) return reject()
              CollectionObject.find(value).then(response => {
                this.matches[value] = response.body
                resolve()
              }, () => {
                this.matches[value] = {}
                reject()
              })
            }
          }).catch(e => {}))
          position++
        }
      }
      Promise.all(promises).then(() => {
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

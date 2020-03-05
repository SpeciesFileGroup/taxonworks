<template>
  <div>
    <spinner-component
      v-if="isSaving"
      :full-screen="true"
      legend="Saving..."/>
    <h1>Manage controlled vocabulary</h1>
    <switch-component
      v-model="view"
      :options="types"/>
    <h3>{{ cvtTypes[view] }}</h3>
    <div class="flex-separate margin-medium-top">
      <div class="panel content full_width">
        <form
          @submit="createCTV"
          class="label-above">
          <div class="field">
            <label>Name</label>
            <input
              class="full_width"
              type="text"
              v-model="controlled_vocabulary_term.name">
          </div>
          <div class="field">
            <label>Definition</label>
            <textarea
              class="full_width"
              rows="5"
              v-model="controlled_vocabulary_term.definition">
            </textarea>
          </div>
          <div class="field">
            <label>CSS Color</label>
            <input
              type="color"
              v-model="controlled_vocabulary_term.css_color">
          </div>
          <div class="field">
            <label>Uri</label>
            <input
              type="text"
              v-model="controlled_vocabulary_term.uri">
          </div>
          <div class="field">
            <label>Uri relation</label>
            <select v-model="controlled_vocabulary_term.uri_relation">
              <option
                v-for="item in uriRelationTypes"
                :key="item"
                :value="item">
                {{ item }}
              </option>
            </select>
          </div>
          <button
            type="submit"
            class="button normal-input button-submit"
            :disabled="!validateData">
            {{ controlled_vocabulary_term.id ? 'Update' : 'Create' }}
          </button>
        </form>
      </div>
      <list-component
        ref="list"
        @edit="setCTV"
        :type="controlled_vocabulary_term.type"/>
    </div>
  </div>
</template>

<script>

import URI_RELATION_TYPES from './constants/uri_relation_types'
import CVT_TYPES from './constants/controlled_vocabulary_term_types'
import { CONTROLLED_VOCABULARY_TERM } from './constants/controlled_vocabulary_term'

import { CreateControlledVocabularyTerm, UpdateControlledVocabularyTerm } from './request/resources'

import SwitchComponent from 'components/switch.vue'
import ListComponent from './components/List.vue'
import SpinnerComponent from 'components/spinner'

export default {
  components: {
    SwitchComponent,
    ListComponent,
    SpinnerComponent
  },
  computed: {
    types () {
      return Object.keys(this.cvtTypes)
    },
    validateData () {
      return (this.controlled_vocabulary_term.name.length > 0 && this.controlled_vocabulary_term.definition.length >= 20)
    }
  },
  data () {
    return {
      cvtTypes: CVT_TYPES,
      uriRelationTypes: URI_RELATION_TYPES,
      controlled_vocabulary_term: CONTROLLED_VOCABULARY_TERM(),
      isSaving: false,
      view: 'Keyword'
    }
  },
  watch: {
    view: { 
      handler(newVal) {
        this.controlled_vocabulary_term.type = newVal
      },
      immediate: true
    }
  },
  methods: {
    capitalizeString (line) {
      return line.split(' ').map(word => { return work.charAt(0).toUpperCase() }).join('')
    },
    createCTV (e) {
      this.isSaving = true
      if(this.controlled_vocabulary_term.id) {
        UpdateControlledVocabularyTerm(this.controlled_vocabulary_term).then(response => {
          this.afterSave(response.body)
          TW.workbench.alert.create(`${response.body.type} was successfully updated.`, 'notice')
        }, (error) => {
          TW.workbench.alert.create(response.bodyText, 'error')
        })
      } else {
        CreateControlledVocabularyTerm(this.controlled_vocabulary_term).then(response => {
          this.afterSave(response.body)
          TW.workbench.alert.create(`${this.view} was successfully created.`, 'notice')
        }, (error) => {
          TW.workbench.alert.create(response.bodyText, 'error')
        })
      }
      e.preventDefault()
    },
    setCTV(ctv) {
      this.controlled_vocabulary_term = ctv
    },
    afterSave(ctv) {
      this.$refs.list.addCTV(ctv)
      this.isSaving = false
      this.controlled_vocabulary_term = CONTROLLED_VOCABULARY_TERM()
      this.controlled_vocabulary_term.type = this.view
    }
  }
}
</script>
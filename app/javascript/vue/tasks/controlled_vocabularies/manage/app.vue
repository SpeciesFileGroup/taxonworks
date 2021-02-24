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
    <h3>
      {{ cvtTypes[view] }}
      <a
        v-if="linkFor.includes(view)"
        href="/tasks/controlled_vocabularies/biocuration/build_collection">Manage biocuration classes and groups
      </a>
    </h3>
    <div class="flex-separate margin-medium-top">
      <div class="one_quarter_width">
      <div class="panel content ">
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
          <button
            type="submit"
            class="button normal-input button-submit"
            :disabled="!validateData">
            {{ controlled_vocabulary_term.id ? 'Update' : 'Create' }}
          </button>
        </form>
      </div>
      </div>
      <list-component
        ref="list"
        @edit="setCTV"
        :type="controlled_vocabulary_term.type"/>
    </div>
  </div>
</template>

<script>

import CVT_TYPES from './constants/controlled_vocabulary_term_types'
import { CONTROLLED_VOCABULARY_TERM } from './constants/controlled_vocabulary_term'

import { CreateControlledVocabularyTerm, UpdateControlledVocabularyTerm, GetControlledVocabularyTerm } from './request/resources'

import SwitchComponent from 'components/switch.vue'
import ListComponent from './components/List.vue'
import SpinnerComponent from 'components/spinner'

import CloneFromObject from 'helpers/cloneFromObject'

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
      controlled_vocabulary_term: CONTROLLED_VOCABULARY_TERM(),
      isSaving: false,
      view: 'Keyword',
      linkFor: ['BiocurationClass', 'BiocurationGroup']
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
  mounted () {
    let urlParams = new URLSearchParams(window.location.search)
    let ctvId = urlParams.get('controlled_vocabulary_term_id')

    if (/^\d+$/.test(ctvId)) {
      GetControlledVocabularyTerm(ctvId).then(response => {
        this.view = response.body.type
        this.setCTV(response.body)
      })
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
        }, () => {
          this.isSaving = false
        })
      } else {
        CreateControlledVocabularyTerm(this.controlled_vocabulary_term).then(response => {
          this.afterSave(response.body)
          this.isSaving = false
          TW.workbench.alert.create(`${this.view} was successfully created.`, 'notice')
        }, () => {
          this.isSaving = false
        })
      }
      e.preventDefault()
    },
    setCTV(ctv) {
      this.controlled_vocabulary_term = CloneFromObject(CONTROLLED_VOCABULARY_TERM(), ctv)
    },
    afterSave(ctv) {
      this.$refs.list.addCTV(ctv)
      this.controlled_vocabulary_term = CONTROLLED_VOCABULARY_TERM()
      this.controlled_vocabulary_term.type = this.view
    }
  }
}
</script>
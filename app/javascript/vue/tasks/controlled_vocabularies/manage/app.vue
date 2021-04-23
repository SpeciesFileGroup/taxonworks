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
        <div class="panel content margin-medium-bottom">
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
            <div
              class="field"
              v-help.new.definition>
              <label>Definition</label>
              <textarea
                class="full_width"
                placeholder="Definition (minimum length 20 characters)"
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
            <div class="flex-separate">
              <button
                type="submit"
                class="button normal-input button-submit"
                :disabled="!validateData">
                {{ controlled_vocabulary_term.id ? 'Update' : 'Create' }}
              </button>
              <button
                type="button"
                class="button normal-input button-default"
                @click="newCTV">
                New
              </button>
            </div>
          </form>
        </div>
        <div
          v-if="globalId"
          class="panel content">
          <h3>Preview use</h3>
          <span
            class="link"
            @click="copyToClipboard">{{ globalId }}</span>
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
    },

    globalId () {
      return this.controlled_vocabulary_term?.global_id
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

  created () {
    const urlParams = new URLSearchParams(window.location.search)
    const ctvId = urlParams.get('controlled_vocabulary_term_id')

    if (/^\d+$/.test(ctvId)) {
      GetControlledVocabularyTerm(ctvId).then(response => {
        this.view = response.body.type
        this.setCTV(response.body)
      })
    }
  },

  methods: {
    createCTV (e) {
      this.isSaving = true
      const saveFn = this.controlled_vocabulary_term.id ? UpdateControlledVocabularyTerm : CreateControlledVocabularyTerm

      saveFn(this.controlled_vocabulary_term).then(({ body }) => {
        TW.workbench.alert.create(`${body.type} was successfully ${this.controlled_vocabulary_term.id ? 'updated' : 'created'}.`, 'notice')
        this.$refs.list.addCTV(body)
        this.newCTV()
      }).finally(() => {
        this.isSaving = false
      })
      e.preventDefault()
    },

    newCTV () {
      this.controlled_vocabulary_term = CONTROLLED_VOCABULARY_TERM()
      this.controlled_vocabulary_term.type = this.view
    },

    setCTV (ctv) {
      this.controlled_vocabulary_term = CloneFromObject(CONTROLLED_VOCABULARY_TERM(), ctv)
    },

    copyToClipboard () {
      navigator.clipboard.writeText(this.controlled_vocabulary_term.global_id).then(() => {
        TW.workbench.alert.create('Copied to clipboard', 'notice')
      })
    }
  }
}
</script>

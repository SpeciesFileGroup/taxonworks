<template>
  <div>
    <spinner-component
      v-if="isSaving"
      full-screen
      legend="Saving..."/>

    <div class="flex-separate middle">
      <h1>Manage controlled vocabulary</h1>
      <ul class="context-menu">
        <li>
          <a :href="routeNames.ManageBiocurationTask">Manage biocuration classes and groups</a>
        </li>
      </ul>
    </div>

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
          <FormKeyword
            v-model="controlled_vocabulary_term"
            @submit="createCTV"
          />
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
import makeControlledVocabularyTerm from 'factory/controlledVocabularyTerm'
import { ControlledVocabularyTerm } from 'routes/endpoints'

import SwitchComponent from 'components/switch.vue'
import ListComponent from './components/List.vue'
import SpinnerComponent from 'components/spinner'
import FormKeyword from 'components/Form/FormKeyword.vue'

import CloneFromObject from 'helpers/cloneFromObject'
import { RouteNames } from 'routes/routes'

export default {
  components: {
    SwitchComponent,
    ListComponent,
    SpinnerComponent,
    FormKeyword
  },

  computed: {
    types () {
      return Object.keys(this.cvtTypes)
    },

    validateData () {
      return (this.controlled_vocabulary_term.name.length > 0 && this.controlled_vocabulary_term.definition.length >= this.definitionLength)
    },

    globalId () {
      return this.controlled_vocabulary_term?.global_id
    },

    routeNames () {
      return RouteNames
    }
  },

  data () {
    return {
      cvtTypes: CVT_TYPES,
      controlled_vocabulary_term: makeControlledVocabularyTerm(),
      isSaving: false,
      view: 'Keyword',
      linkFor: ['BiocurationClass', 'BiocurationGroup'],
      definitionLength: 20
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
      ControlledVocabularyTerm.find(ctvId).then(response => {
        this.view = response.body.type
        this.setCTV(response.body)
      })
    }
  },

  methods: {
    createCTV () {
      const controlled_vocabulary_term = this.controlled_vocabulary_term
      const savePromise = this.controlled_vocabulary_term.id
        ? ControlledVocabularyTerm.update(controlled_vocabulary_term.id, { controlled_vocabulary_term })
        : ControlledVocabularyTerm.create({ controlled_vocabulary_term })

      this.isSaving = true

      savePromise.then(({ body }) => {
        TW.workbench.alert.create(`${body.type} was successfully ${this.controlled_vocabulary_term.id ? 'updated' : 'created'}.`, 'notice')
        this.$refs.list.addCTV(body)
        this.newCTV()
      }).finally(() => {
        this.isSaving = false
      })
    },

    newCTV () {
      this.controlled_vocabulary_term = makeControlledVocabularyTerm()
      this.controlled_vocabulary_term.type = this.view
    },

    setCTV (ctv) {
      this.controlled_vocabulary_term = CloneFromObject(makeControlledVocabularyTerm(), ctv)
    },

    copyToClipboard () {
      navigator.clipboard.writeText(this.controlled_vocabulary_term.global_id).then(() => {
        TW.workbench.alert.create('Copied to clipboard', 'notice')
      })
    }
  }
}
</script>

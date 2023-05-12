<template>
  <div>
    <div class="flex-separate middle">
      <h1>New source from BibTeX</h1>
      <span
        @click="resetApp"
        class="reload-app"
        data-icon="reset">Reset
      </span>
    </div>
    <div class="feedback feedback-warning">
      This task is deprecated. <a href="/tasks/sources/new_source">New source</a> now provides the same functionality and includes parse error reporting.
    </div>
    <a href="/tasks/sources/hub/index">Back to source hub</a>
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"
    />

    <p> <i> Creates a single record. For multiple records use a Source batch loader.</i> </p>
    <div class="flexbox">
      <div class="flexbox">
        <div class="separate-right">
          <div class="last_name separate-right">
            <h2>BibTeX Input</h2>
            <bibtex-input v-model="bibtexInput" />
          </div>
          <br>
          <br>
          <br>
          <button
            class="button normal-input button-default"
            @click="parseBibtex"
            :disabled="!enableParseBibtex"
            type="submit">Parse BibTeX
          </button>
          &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
          <button
            class="button normal-input button-submit"
            @click="createSource"
            :disabled="!enableCreateBibtex"
            type="submit">Create source from BibTeX
          </button>
          <br>
          <br>
          <span>{{ showCreatedSourceID }}</span>
        </div>
        <div
          class="flex-separate top separate-left">
          <div>
            <h2>Parsed BibTeX</h2>
            <table-bibtex :bibtex="parsedBibtex"/>
          </div>
        </div>
      </div>
    </div>
    <div
      class="flex-separate top">
      <div>
        <h2>Recently created</h2>
        <table-recent :list="recentCreated"/>
      </div>
    </div>
  </div>
</template>

<script>
import BibtexInput from './components/bibtex_input'
import TableBibtex from './components/tableBibtex'
import Spinner from '../../components/spinner.vue'
import TableRecent from './components/recentTable'
import { Source } from 'routes/endpoints'

export default {
  components: {
    BibtexInput,
    TableBibtex,
    TableRecent,
    Spinner
  },

  computed: {
    enableParseBibtex () {
      return this.bibtexInput.length > 0
    },

    enableCreateBibtex () {
      return (!this.parsedBibtex.hasOwnProperty('status') && Object.keys(this.parsedBibtex).length)
    },

    showCreatedSourceID () {
      let retVal = ''
      if (this.parsedBibtex.source) {
        if (this.parsedBibtex.source.id) {
          retVal = 'Created Source: ' + this.parsedBibtex.source.id
        }
      }
      return retVal
    }
  },

  data () {
    return {
      bibtexInput: '',
      isLoading: false,
      parsedBibtex: {},
      recentCreated: []
    }
  },

  watch: {
    parsedBibtex () {
      this.isLoading = false
    }
  },

  created () {
    this.loadRecent()
  },

  methods: {
    loadRecent () {
      Source.where({ recent: true, per: 15 }).then(response => {
        this.recentCreated = response.body
      })
    },

    parseBibtex () {
      this.isLoading = true

      Source.parse({ bibtex_input: this.bibtexInput }).then(response => {
        this.parsedBibtex = response.body
        this.unlockCreate = !response.body.hasOwnProperty('status')
        this.isLoading = false
      })
    },

    resetApp () {
      this.bibtexInput = ''
      this.clearParsedData()
    },

    createSource () {
      this.isLoading = true

      Source.create({ bibtex_input: this.bibtexInput }).then(response => {
        this.parsedBibtex = {}
        this.recentCreated.unshift(response.body)
        this.bibtexInput = ''
        this.isLoading = false
      })
    }
  }
}
</script>

<template>
  <div>
    <spinner-component
      :full-screen="true"
      v-if="isLoading"/>
    <button
      type="button"
      class="button normal-input button-default"
      :disabled="params.source_type != sourceType && params.source_type != undefined"
      @click="loadBibtexStyle">
      Download formatted
    </button>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Bibliography</h3>
      <div slot="body">
        <label class="display-block">Style</label>
        <select
          class="margin-small-bottom"
          v-model="styleId">
          <option
            v-for="(label, key) in bibtexStyle"
            :value="key"
            :key="key">
            {{ label }}
          </option>
        </select>
        <textarea
          class="full_width"
          :value="bibtex">
        </textarea>
      </div>
      <div slot="footer">
        <button
          v-if="!links"
          type="button"
          class="button normal-input button-default"
          :disabled="!bibtex"
          @click="generateLinks">
          Generate download
        </button>
        <template v-else>
          <span>Share link:</span>
          <div
            class="middle">
            <pre class="margin-small-right">{{ links.api_file_url ? links.api_file_url : noApiMessage }}</pre>
            <clipboard-button
              v-if="links.api_file_url"
              :text="links.api_file_url"/>
          </div>
        </template>
        <button
          :disabled="!bibtex"
          type="button"
          @click="createDownloadLink()"
          class="button normal-input button-default">
          Download Bibtex
        </button>
      </div>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/modal'
import SpinnerComponent from 'components/spinner'
import ClipboardButton from 'components/clipboardButton'

import { GetBibliography, GetBibtexStyle, GetBibtex } from '../request/resources'
import { downloadTextFile } from 'helpers/files.js'

export default {
  components: {
    ModalComponent,
    SpinnerComponent,
    ClipboardButton
  },
  props: {
    params: {
      type: Object,
      default: undefined
    },
    pagination: {
      type: Object,
      default: undefined
    },
    selectedList: {
      type: Array,
      default: () => []
    }
  },
  data () {
    return {
      bibtex: undefined,
      isLoading: false,
      url: undefined,
      showModal: false,
      links: undefined,
      sourceType: 'Source::Bibtex',
      noApiMessage: 'To share your project administrator must create an API token.',
      bibtexStyle: undefined,
      styleId: undefined
    }
  },
  watch: {
    params: {
      handler (newVal) {
        this.links = undefined
      },
      deep: true
    },
    styleId: {
      handler (newVal) {
        this.loadBibliography()
      }
    }
  },
  methods: {
    async loadBibtexStyle () {
      this.showModal = true
      this.isLoading = true
      GetBibtexStyle().then(response => {
        this.bibtexStyle = Object.fromEntries(Object.entries(response.body).sort())
        this.isLoading = false
      })
    },
    createDownloadLink () {
      downloadTextFile(this.bibtex, 'text/bib', 'bibliography.bib')
    },
    generateLinks () {
      return new Promise((resolve, reject) => {
        this.isLoading = true
        GetBibliography({ params: Object.assign({}, (this.selectedList.length ? { ids: this.selectedList } : this.params), { is_public: true, style_id: this.styleId, per: this.pagination.total }) }).then(response => {
          this.links = response.body
          this.isLoading = false
        })
      })
    },
    loadBibliography () {
      return new Promise((resolve, reject) => {
        this.isLoading = true
        GetBibtex({ params: Object.assign({}, (this.selectedList.length ? { ids: this.selectedList } : this.params), { is_public: true, style_id: this.styleId }) }).then(response => {
          this.links = undefined
          this.bibtex = response.body
          this.isLoading = false
          resolve(response)
        })
      })
    }
  }
}
</script>
<style scoped>
  /deep/ .modal-container {
    min-width: 80vw;
    min-height: 60vh;
  }
  textarea {
    height: 60vh;
  }
</style>

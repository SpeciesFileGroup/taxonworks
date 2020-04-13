<template>
  <div>
    <spinner-component
      :full-screen="true"
      v-if="isLoading"/>
    <button
      type="button"
      class="button normal-input button-default"
      @click="loadBibtex">
      Generate bibtex
    </button>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Bibtex</h3>
      <div slot="body">
        <textarea
          class="full_width"
          :value="bibtex">
        </textarea>
      </div>
      <div slot="footer">
        <p>Share link:</p>
        <div class="middle">
          <pre class="margin-small-right">{{ url }}</pre>
          <clipboard-button
            :text="url"/>
        </div>
      </div>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/modal'
import SpinnerComponent from 'components/spinner'
import ClipboardButton from 'components/clipboardButton'

import { GetBibtex } from '../request/resources'

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
    }
  },
  data () {
    return {
      bibtex: undefined,
      isLoading: false,
      url: undefined,
      showModal: false
    }
  },
  methods: {
    loadBibtex () {
      this.showModal = true
      this.isLoading = true
      GetBibtex(this.params).then(response => {
        this.url = `${window.location.protocol}//${window.location.host}${response.url}`
        this.bibtex = response.body
        this.isLoading = false
      })
    }
  }
}
</script>
<style scoped>
  textarea {
    height: 60vh;
  }
  
  /deep/ .modal-container {
    min-width: 80vw;
    min-height: 60vh;
  }
</style>

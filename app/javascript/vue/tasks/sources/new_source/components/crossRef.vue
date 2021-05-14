<template>
  <modal-component
    @close="$emit('close', true)"
    :containerStyle="{ 'overflow-y': 'scroll', 'max-height': '80vh' }"
    class="full_width">
    <h3 slot="header">Create a source from a verbatim citation or DOI</h3>
    <div slot="body">
      <spinner-component
        v-if="searching"
        :full-screen="true"
        legend="Searching..."/>
      <ul>
        <li> Submit either a DOI or full citation. </li>
        <li> DOIs should be in the form of <pre>https://doi.org/10.1145/3274442</pre> or <pre>10.1145/3274442</pre> or <pre>doi:10.1145/3274442</pre> </li>
        <li> The query will be resolved against <a href="https://www.crossref.org/">CrossRef</a>. </li>
        <li> If there is a hit, then you will be given the option to import the parsed citation.  This is the BibTeX format. </li>
        <li> If there is no hit, you have the option to import the record as a single field. This is the Verbatim format. </li>
        <li> The created source is automatically added to the current project. </li>
        <li> <em>Not all hits are correct!  Check that the result matches the query.</em> </li>
      </ul>
      <textarea 
        class="full_width"
        v-model="citation"
        placeholder="DOI or citation to find...">
      </textarea>
      <div
        class="flex-separate separate-top"
        slot="footer">
        <button
          @click="getSource"
          :disabled="!citation.length"
          class="button normal-input button-default"
          type="button">
          Find
        </button>
        <button
          v-if="!found"
          @click="setVerbatim"
          class="button normal-input button-default"
          type="button">
          Set as verbatim
        </button>
      </div>
    </div>
  </modal-component>
</template>

<script>

import AjaxCall from 'helpers/ajaxCall'
import SpinnerComponent from 'components/spinner'
import ModalComponent from 'components/ui/Modal'
import { MutationNames } from '../store/mutations/mutations'
import { Serial } from 'routes/endpoints'

export default {
  components: {
    ModalComponent,
    SpinnerComponent
  },
  data () {
    return {
      citation: '',
      searching: false,
      found: true
    }
  },
  methods: {
    getSource () {
      this.searching = true
      AjaxCall('get', `/tasks/sources/new_source/crossref_preview.json?citation=${this.citation}`).then(response => {
        if (response.body.title) {
          response.body.roles_attributes = []
          this.$store.commit(MutationNames.SetSource, response.body)
          this.$emit('close', true)
          Serial.where({ name: response.body.journal }).then(response => {
            if (response.body.length) {
              this.$store.commit(MutationNames.SetSerialId, response.body[0].id)
            }
          })
          TW.workbench.alert.create('Found! (please check).', 'notice')
        }
        else {
          this.found = false
          TW.workbench.alert.create('Nothing found or the source already exist.', 'error')
        }
        this.searching = false
      }, () => {
        this.searching = false
      })
    },
    setVerbatim () {
      this.$store.commit(MutationNames.SetSource, { type: 'Source::Verbatim', verbatim: this.citation })
      this.$emit('close', true)
    }
  }
}
</script>

<style scoped>
  ::v-deep .modal-container {
    width: 500px;
  }
  textarea {
    height: 100px;
  }
</style>
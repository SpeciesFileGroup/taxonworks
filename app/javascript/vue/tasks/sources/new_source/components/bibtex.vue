<template>
  <modal-component
    @close="$emit('close', true)"
    class="full_width">
    <template #header>
      <h3>New source from BibTeX</h3>
    </template>
    <template #body>
      <spinner-component
        v-if="creating"
        :full-screen="true"
        legend="Creating..."/>
      <p>Creates a single record. For multiple records use a Source batch loader.</p>
      <textarea 
        class="full_width"
        v-model="bibtexInput"
        placeholder="@article{naumann1988ambositrinae,
          title={Ambositrinae (Insecta: Hymenoptera: Diapriidae)},
          author={Naumann, Ian D},
          journal={Fauna of New Zealand},
          volume={15},
          year={1988}
      }"/>
    </template>
    <template #footer>
      <div class="flex-separate separate-top">
        <button
          @click="createSource"
          :disabled="!bibtexInput.length"
          class="button normal-input button-default"
          type="button">
          Create
        </button>
      </div>
    </template>
  </modal-component>
</template>

<script>

import AjaxCall from 'helpers/ajaxCall'
import SpinnerComponent from 'components/spinner'
import { MutationNames } from '../store/mutations/mutations'
import ModalComponent from 'components/ui/Modal'

export default {
  components: {
    ModalComponent,
    SpinnerComponent
  },
  data() {
    return {
      bibtexInput: '',
      creating: false,
      recentCreated: []
    };
  },
  methods: {
    createSource() {
      this.creating = true
      AjaxCall('post', '/sources.json', { bibtex_input: this.bibtexInput }).then(response => {
        this.bibtexInput = ""
        this.creating = false
        this.$emit('close', true)
        this.$store.commit(MutationNames.SetSource, response.body)
        TW.workbench.alert.create('New source from BibTeX created.', 'notice')
      }, () => {
        this.creating = false
        TW.workbench.alert.create('Wrong data', 'error')
      }) 
    }
  }
}
</script>

<style scoped>
  :deep(.modal-container) {
    width: 500px;
  }
  textarea {
    height: 200px;
  }
</style>
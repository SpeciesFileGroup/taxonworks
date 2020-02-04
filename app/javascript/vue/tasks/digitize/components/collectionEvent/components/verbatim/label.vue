<template>
  <div>
    <label>Label</label>
    <textarea
      rows="5"
      @blur="searchCE"
      v-model="label"/>
    <clone-label/>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Collecting events match</h3>
      <div slot="body">
        <table-component
          :list="CEFounded"
          :edit="true"
          :delete="false"
          :annotator="false"
          @edit="loadCE"
          :attributes="['object_tag']"/>
      </div>
    </modal-component>
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters'
import { MutationNames } from '../../../../store/mutations/mutations'
import CloneLabel from './cloneLabel'
import { GetCEMd5Label } from '../../../../request/resources'
import ModalComponent from 'components/modal'
import TableComponent from 'components/table_list'

export default {
  components: {
    CloneLabel,
    ModalComponent,
    TableComponent
  },
  computed: {
    label: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].verbatim_label
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventLabel, value)
      }
    }
  },
  data () {
    return {
      showModal: false,
      CEFounded: []
    }
  },
  methods: {
    searchCE () {
      if(this.label) {
        GetCEMd5Label(this.label).then(response => {
          if(response.length) {
            this.CEFounded = response
            this.showModal = true
          }
        })
      }
    },
    loadCE (ce) {
      this.$store.commit(MutationNames.SetCollectionEvent, ce)
      this.showModal = false
    }
  }
}
</script>
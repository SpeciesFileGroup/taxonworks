<template>
  <div>
    <button
      @click="setModalView(true)"
      class="button normal-input button-default">
      Settings
    </button>
    <modal-component
      v-show="showModal"
      @close="setModalView(false)"
      :container-style="{
        width: '700px',
        maxHeight: '80vh',
        overflow: 'scroll'
      }">
      <h3 slot="header">Settings</h3>
      <div slot="body">
        <div><containerize-checkbox/></div>
        <div><restrict-to-nomenclature-checkbox/></div>
        <h3>Catalog number namespace mapping</h3>
        <table class="full_width">
          <thead>
            <tr>
              <th>institutionCode</th>
              <th>collectionCode</th>
              <th>Namespace</th>
            </tr>
          </thead>
          <tbody>
            <row-component
              class="contextMenuCells"
              v-for="(item, index) in catalogueNumbers"
              :row="item"
              :dataset-id="dataset.id"
              :key="index"
              @onUpdate="updateChanges"
              @onRemove="updateChanges"/>
          </tbody>
        </table>
      </div>
    </modal-component>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { ActionNames } from '../../store/actions/actions'
import ModalComponent from 'components/modal'
import RowComponent from './Row'
import ContainerizeCheckbox from './Containerize'
import RestrictToNomenclatureCheckbox from './RestrictToNomenclature'

export default {
  components: {
    ContainerizeCheckbox,
    RestrictToNomenclatureCheckbox,
    ModalComponent,
    RowComponent
  },
  computed: {
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    },
    dataset () {
      return this.$store.getters[GetterNames.GetDataset]
    },
    catalogueNumbers () {
      return this.dataset.metadata?.catalog_numbers_namespaces || []
    }
  },
  data () {
    return {
      showModal: false,
      needUpdate: false
    }
  },
  watch: {
    showModal (newVal) {
      if (newVal) {
        this.needUpdate = false
        this.$store.dispatch(ActionNames.LoadDataset, this.dataset.id)
      } else {
        if (this.needUpdate) {
          this.reloadDataset()
        }
      }
    }
  },
  methods: {
    setModalView (value) {
      this.showModal = value
    },
    reloadDataset () {
      this.$store.dispatch(ActionNames.LoadDataset, this.dataset.id)
      this.$store.dispatch(ActionNames.LoadDatasetRecords)
    },
    updateChanges () {
      this.needUpdate = true
    }
  }
}
</script>

<template>
  <div>
    <button
      @click="setModalView(true)"
      class="button normal-input button-default">
      Settings
    </button>
    <modal-component
      v-if="showModal"
      @close="setModalView(false)"
      :container-style="{
        width: '700px'
      }">
      <h3 slot="header">Settings</h3>
      <div slot="body">
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
              @update="reloadDataset"/>
          </tbody>
        </table>
      </div>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/modal'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { ActionNames } from '../../store/actions/actions'

import RowComponent from './Row'

export default {
  components: {
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
      return this.dataset.metadata.catalog_numbers_namespaces
    }
  },
  data () {
    return {
      showModal: false
    }
  },
  watch: {
    showModal (newVal) {
      if (!newVal) {
        this.reloadDataset()
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
    }
  }
}
</script>

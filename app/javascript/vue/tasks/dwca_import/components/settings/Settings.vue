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
        width: '700px',
        maxHeight: '80vh',
        overflow: 'scroll'
      }">
      <template #header>
        <h3>Settings</h3>
      </template>
      <template #body>
        <div>
          <nomenclature-code class="margin-medium-bottom"/>

          <div class="field">
            <containerize-checkbox />
            <restrict-to-nomenclature-checkbox />
            <require-type-material-success-checkbox />
          </div>

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
              <catalog-number-row
                v-for="(item, index) in catalogueNumbers"
                class="contextMenuCells"
                :row="item"
                :dataset-id="dataset.id"
                :key="index"
                @update="updateChanges($event, index)"
              />
            </tbody>
          </table>
        </div>
      </template>
    </modal-component>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { ActionNames } from '../../store/actions/actions'
import ModalComponent from 'components/ui/Modal'
import CatalogNumberRow from './CatalogNumberRow'
import ContainerizeCheckbox from './Containerize'
import RestrictToNomenclatureCheckbox from './RestrictToNomenclature'
import RequireTypeMaterialSuccessCheckbox from './RequireTypeMaterialSuccess'
import NomenclatureCode from './NomenclatureCode.vue'

export default {
  components: {
    ContainerizeCheckbox,
    RestrictToNomenclatureCheckbox,
    RequireTypeMaterialSuccessCheckbox,
    ModalComponent,
    CatalogNumberRow,
    NomenclatureCode
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

  created () {
    const namespaceIds = this.catalogueNumbers.map(item => item.namespace_id).filter(id => id)

    this.$store.dispatch(ActionNames.LoadNamespaces, namespaceIds)
  },

  methods: {
    setModalView (value) {
      this.showModal = value
    },

    reloadDataset () {
      this.$store.dispatch(ActionNames.LoadDataset, this.dataset.id)
      this.$store.dispatch(ActionNames.LoadDatasetRecords)
    },

    updateChanges (data, index) {
      this.dataset.metadata.catalog_numbers_namespaces[index] = data
      this.needUpdate = true
    }
  }
}
</script>

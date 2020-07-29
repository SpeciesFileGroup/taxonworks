<template>
  <navbar-component
    :component-style="{
      position: 'fixed',
      bottom: '0px',
      zIndex: 200,
      margin: '0px'
    }">
    <div class="flex-separate middle">
      <div>
        <span v-if="pagination">{{ datasetRecords.length }} of {{ pagination.total }} records.</span>
      </div>
      <div>
        <button
          class="button normal-input button-default margin-small-right"
          @click="selectAll">
          Select all
        </button>
        <button
          class="button normal-input button-default margin-small-right"
          @click="unselectAll">
          Unselect all
        </button>
        <import-modal/>
      </div>
    </div>
  </navbar-component>
</template>

<script>

import NavbarComponent from 'components/navBar'
import ImportModal from './ImportModal'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  components: {
    NavbarComponent,
    ImportModal
  },
  computed: {
    pagination () {
      return this.$store.getters[GetterNames.GetPagination]
    },
    dataset () {
      return this.$store.getters[GetterNames.GetDataset]
    },
    datasetRecords () {
      return this.$store.getters[GetterNames.GetDatasetRecords]
    }
  },
  methods: {
    selectAll () {
      this.$store.commit(MutationNames.SetSelectedRowIds, this.datasetRecords.filter(row => row.status === 'Ready').map(row => row.id))
    },
    unselectAll () {
      this.$store.commit(MutationNames.SetSelectedRowIds, [])
    }
  }
}
</script>

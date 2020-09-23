<template>
  <navbar-component
    :component-style="{
      position: 'fixed',
      bottom: '0px',
      zIndex: 200,
      margin: '0px'
    }">
    <div class="flex-separate middle">
      <div class="half_width">
        <span v-if="pagination">{{ pagination.total }} records.</span>
      </div>
      <div class="full_width">
        <progress-bar class="full_width" :progress="dataset.progress"/>
        <progress-list class="context-menu" :progress="dataset.progress"/>
      </div>
      <div class="horizontal-right-content half_width">
        <button
          class="button normal-input button-submit margin-small-right"
          @click="settings">
          Settings
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
import ProgressBar from './ProgressBar'
import ProgressList from './ProgressList'

export default {
  components: {
    NavbarComponent,
    ImportModal,
    ProgressBar,
    ProgressList
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
    settings () {
      alert('Coming soon')
    }
  }
}
</script>

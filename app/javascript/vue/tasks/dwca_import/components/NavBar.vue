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
        <span>{{ dataset.description}}</span>
        <span>-</span>
        <span v-if="pagination">{{ pagination.total }} records.</span>
      </div>
      <div class="full_width">
        <progress-bar
          class="full_width"
          :progress="dataset.progress"/>
        <progress-list
          class="context-menu"
          :progress="dataset.progress"/>
      </div>
      <div class="horizontal-right-content half_width">
        <settings-component class="margin-small-right"/>
        <import-modal/>
        <button
          type="button"
          class="button normal-input button-default margin-small-left"
          @click="reset"
        >
          Back
        </button>
      </div>
    </div>
  </navbar-component>
</template>

<script>

import NavbarComponent from 'components/layout/NavBar'
import ImportModal from './ImportModal'
import ProgressBar from './ProgressBar'
import ProgressList from './ProgressList'
import SettingsComponent from './settings/Settings'
import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'

export default {
  components: {
    NavbarComponent,
    ImportModal,
    ProgressBar,
    ProgressList,
    SettingsComponent
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
    reset () {
      this.$store.dispatch(ActionNames.ResetState)
    }
  }
}
</script>

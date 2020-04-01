<template>
  <modal-component
    @close="$emit('close', true)"
    class="full_width">
    <h3 slot="header">Recent</h3>
    <div slot="body">
      <spinner-component v-if="searching"/>
      <table-list
        :header="['cached', '']"
        :annotator="false"
        :destroy="false"
        :edit="true"
        :attributes="['cached']"
        @edit="setSource"
        :list="sources"/>
    </div>
  </modal-component>
</template>

<script>

import TableList from 'components/table_list'
import SpinnerComponent from 'components/spinner'
import { ActionNames } from '../store/actions/actions'
import ModalComponent from 'components/modal'

import { GetRecentSources } from '../request/resources'

export default {
  components: {
    ModalComponent,
    SpinnerComponent,
    TableList
  },
  data () {
    return {
      sources: [],
      searching: false
    }
  },
  mounted () {
    this.getSources()
  },
  methods: {
    getSources () {
      this.searching = true
      GetRecentSources().then(response => {
        this.sources = response.body
        this.searching = false
      })
    },
    setSource (source) {
      this.$store.dispatch(ActionNames.LoadSource, source.id)
      this.$emit('close', true)
    }
  }
}
</script>

<style scoped>
  /deep/ .modal-container {
    width: 500px;
  }
  textarea {
    height: 100px;
  }
  /deep/ .modal-container {
    width: 800px !important;
  }
</style>
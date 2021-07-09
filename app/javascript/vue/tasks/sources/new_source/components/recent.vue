<template>
  <modal-component
    @close="$emit('close', true)"
    class="full_width">
    <template #header>
      <h3>Recent</h3>
    </template>
    <template #body>
      <spinner-component v-if="searching"/>
      <table-list
        :list="sources"
        :attributes="['cached']"
        :header="['cached', '']"
        :annotator="false"
        :destroy="false"
        edit
        @edit="setSource"
      />
    </template>
  </modal-component>
</template>

<script>

import TableList from 'components/table_list'
import SpinnerComponent from 'components/spinner'
import ModalComponent from 'components/ui/Modal'
import { ActionNames } from '../store/actions/actions'
import { Source } from 'routes/endpoints'

export default {
  components: {
    ModalComponent,
    SpinnerComponent,
    TableList
  },

  emits: ['close'],

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
      Source.where({ per: 10, recent: true }).then(response => {
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
  :deep(.modal-container) {
    width: 500px;
  }
  textarea {
    height: 100px;
  }
  :deep(.modal-container) {
    width: 800px !important;
  }
</style>

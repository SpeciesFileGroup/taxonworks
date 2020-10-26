<template>
  <pagination-component
    v-if="pagination"
    @nextPage="loadPage"
    :pagination="virtualPagination"/>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'
import PaginationComponent from 'components/pagination'

export default {
  components: {
    PaginationComponent
  },
  computed: {
    virtualPages () {
      return this.$store.getters[GetterNames.GetVirtualPages]
    },
    pagination () {
      return this.$store.getters[GetterNames.GetPagination]
    },
    currentVirtualPage: {
      get () {
        return this.$store.getters[GetterNames.GetCurrentVirtualPage]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCurrentVirtualPage, value)
      }
    },
    totalRecords () {
      return this.virtualPages[this.currentVirtualPage].total
    },
    virtualPagination () {
      return {
        nextPage: this.currentVirtualPage < Object.keys(this.virtualPages).length ? this.currentVirtualPage + 1 : undefined,
        paginationPage: this.currentVirtualPage,
        perPage: this.pagination.perPage,
        previousPage: this.currentVirtualPage > 1 ? this.currentVirtualPage - 1 : undefined,
        total: this.totalRecords,
        totalPages: Object.keys(this.virtualPages).length
      }
    }
  },
  methods: {
    loadPage (event) {
      this.currentVirtualPage = event.page
      this.$store.dispatch(ActionNames.LoadDatasetRecords)
    }
  }
}
</script>

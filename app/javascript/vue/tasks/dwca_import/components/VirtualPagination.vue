<template>
  <div>
    <pagination-component
      v-if="pagination"
      @nextPage="loadPage"
      :pagination="virtualPagination"/>
    <spinner-component
      v-if="isLoading"
      full-screen/>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'
import PaginationComponent from 'components/pagination'
import SpinnerComponent from 'components/spinner'

export default {
  components: {
    PaginationComponent,
    SpinnerComponent
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
  data () {
    return {
      isLoading: false
    }
  },
  methods: {
    loadPage (event) {
      this.currentVirtualPage = event.page
      this.isLoading = true
      this.$store.dispatch(ActionNames.LoadDatasetRecords).then(response => {
        this.isLoading = false
      })
    }
  }
}
</script>

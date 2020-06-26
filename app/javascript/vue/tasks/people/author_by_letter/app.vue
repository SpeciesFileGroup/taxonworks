<template>
  <div>
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <h1>Author by first letter</h1>
    <alphabet-buttons
      @keypress="key = $event; getAuthors()"
      ref="alphabetButtons"/>
    <pagination-component
      :pagination="pagination"
      @nextPage="getAuthors"/>
    <div class="horizontal-left-content align-start">
      <div class="separate-right">
        <author-list
          :list="authorsList"
          :pagination="pagination"
          @selected="getSources"/>
      </div>
      <div class="separate-left">
        <source-list
          v-show="sourcesList.length"
          :list="sourcesList"/>
      </div>
    </div>
  </div>
</template>
<script>

  import AlphabetButtons from './components/alphabet_buttons'
  import AuthorList from './components/author_list'
  import SourceList from './components/source_list.vue'
  import Spinner from 'components/spinner.vue'
  import PaginationComponent from './components/pagination.vue'

  import GetPagination from 'helpers/getPagination.js'
  import AjaxCall from 'helpers/ajaxCall'

  export default {
    components: {
      AlphabetButtons,
      AuthorList,
      SourceList,
      Spinner,
      PaginationComponent
    },
    data() {
      return {
        authorsList: [],
        sourcesList: [],
        isLoading: false,
        key: undefined,
        pagination: {}
      }
    },
    mounted() {
      let urlParams = new URLSearchParams(window.location.search)
      let letterParam = urlParams.get('letter')
      if(letterParam) {
        letterParam = letterParam.toUpperCase()
      }

      if (/([A-Z])$/.test(letterParam) && letterParam.length == 1) {
        this.key = letterParam
        this.getAuthors()
        this.$refs.alphabetButtons.setSelectedLetter(letterParam)
      }
    },
    methods: {
      getAuthors(args = {}) {
        let params = {
          last_name_starts_with: this.key,
          roles: ['SourceAuthor']
        }
        this.isLoading = true
        AjaxCall('get', `/people.json`, { params: Object.assign({}, args, params) }).then(response => {
          this.authorsList = response.body
          this.pagination = GetPagination(response)
          this.isLoading = false
        })
      },
      getSources(author_id) {
        this.isLoading = true
        AjaxCall('get', `/sources.json?author_ids[]=${author_id}`).then(response => {
          this.sourcesList = response.body;
          this.isLoading = false
          this.$nextTick(() => {
            document.getElementById('source-table').scrollIntoView({ behavior: "smooth" })
          })
          
        })
      },
    }
  }
</script>
<template>
  <div>
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <h1>Author by First Letter</h1>
    <alphabet-buttons
      @keypress="key = $event; getAuthors()"
      ref="alphabetButtons"/>
    <div>
      <author-list
        :list="authorsList"
        :pagination="pagination"
        @selected="getSources"/>
      <pagination-component
        :pagination="pagination"
        @nextPage="getAuthors"/>
      <h2>Sources for selected author</h2>
      <source-list :list="sourcesList"/>
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
        this.$http.get(`/people.json`, { params: Object.assign({}, args, params) }).then(response => {
          console.log(response)
          this.authorsList = response.body
          this.pagination = GetPagination(response)
          this.isLoading = false
        })
      },
      getSources(author_id) {
        this.isLoading = true
        this.$http.get(`/sources.json?author_ids[]=${author_id}`).then(response => {
          this.sourcesList = response.body;
          this.isLoading = false
          document.getElementById('source-table').scrollIntoView({ behavior: "smooth" })
        })
      },
    }
  }
</script>
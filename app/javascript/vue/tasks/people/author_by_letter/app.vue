<template>
  <div>
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <h1>Author by First Letter</h1>
    <alphabet-buttons
      @keypress="getAuthors($event)"
      ref="alphabetButtons"/>
    <div>
      <author-list
        :list="authorsList"
        @selected="getSources"/>
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

  export default {
    components: {
      AlphabetButtons,
      AuthorList,
      SourceList,
      Spinner
    },
    data() {
      return {
        authorsList: [],
        sourcesList: [],
        isLoading: false,
      }
    },
    mounted() {
      let urlParams = new URLSearchParams(window.location.search)
      let letterParam = urlParams.get('letter').toUpperCase()

      if (/([A-Z])$/.test(letterParam) && letterParam.length == 1) {
        this.getAuthors(letterParam)
        this.$refs.alphabetButtons.setSelectedLetter(letterParam)
      }
    },
    methods: {
      getAuthors(key) {
        this.isLoading = true
        this.$http.get(`/people.json?roles[]=SourceAuthor&last_name_starts_with=${key}`).then(response => {
          this.authorsList = response.body;
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
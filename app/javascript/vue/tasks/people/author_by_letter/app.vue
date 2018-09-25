<template>
  <div>
    <h1>Author by First Letter</h1>
    <alphabet-buttons @keypress="getAuthors($event)"/>
    <author-list :list="authorsList"/>
  </div>
</template>
<script>
  import AlphabetButtons from './components/alphabet_buttons'
  import AuthorList from './components/author_list'

  export default {
    components: {
      AlphabetButtons,
      AuthorList
    },
    data() {
      return {
        authorsList: []
      }
    },
    methods: {
      getAuthors(key) {
        // this.$http.get('/people.json?last_name_starts_with=' + key).then(response => {
        this.$http.get('/people.json?roles[]=SourceAuthor&last_name_starts_with=' + key).then(response => {
          this.authorsList = response.body;
        })
      }
    }
  }
</script>
<template>
  <div>
    <h1>Author by First Letter</h1>
    <alphabet-buttons @keypress="getAuthors($event)"/>
    <author-list :list="AuthorsList"/>
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
        AuthorsList: {
          type: Array,
          default: []
        }
      }
    },
    methods: {
      getAuthors(key) {
        this.$http.get('/people.json?last_name_starts_with=' + key).then(response => {
          this.AuthorsList = response.body;
        })
      }
    }
  }
</script>
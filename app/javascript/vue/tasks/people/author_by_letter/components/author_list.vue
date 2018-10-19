<template>
  <div class="flex-separate">
    <div>
    <table>
      <tr>
        <th @click="sortByName">Author</th>
        <th>Sources</th>
        <th>Uniquify</th>
        <th></th>
      </tr>
      <author-row-component
          v-for="item in list"
          :key="item.id"
          @delete="removeAuthor"
          @sources="getSources(item.id)"
          :author="item"/>
    </table>
      <div>
        <h2>Sources for selected author</h2>
      </div>
      <div>
        <table>
          <tr>
            <th>Source</th>
            <th></th>
            <th></th>
          </tr>
          <source-row-component
              v-for="src in sourceList"
              :source="src"/>
        </table>
      </div>
    </div>
  </div>
</template>
<script>

  import AuthorRowComponent from './author_row_component'
  import SourceRowComponent from './source_row_component'

  export default {
    components: {
      AuthorRowComponent,
      SourceRowComponent
    },
    props: {
      list: {
        type: Array,
        required: true
      },
    },
    data() {
      return {
        author: [],
        sources: '',
        sourceList: []
      }
    },
    watch: {
      list() {
        this.sourceList = []
      }
    },
    methods: {
      getSources(author_id) {
        this.$http.get("/sources.json?author_ids[]=" + author_id).then(response => {
          this.sources = response.body;
          this.$emit("sources", this.sources);
          this.sourceList = this.sources;
        })
      },
      removeAuthor(author) {
        let index = this.list.findIndex((item) => {
          return author.id == item.id
        });
        if (index > -1) {
          this.list.splice(index, 1)
        }
      },
      sortByName() {
        function compare(a, b) {
          if (a.pages < b.pages)
            return -1;
          if (a.pages > b.pages)
            return 1;
          return 0;
        }

        this.list.sort(compare);
      }
    }
  }
</script>

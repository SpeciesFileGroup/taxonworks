<template>
  <div class="flex-separate">
    <div>
    <table>
      <tr>
        <th @click="sortByName">Author</th>
        <!--<th>Object</th>-->
        <th>Sources</th>
        <!--<th>Otu</th>-->
        <th>Show</th>
        <th>Uniquify</th>
        <th>Remove</th>
      </tr>
      <row-components
          v-for="item in list"
          @delete="removeAuthor"
          @sources="getSources"
          :author="item"/>
    </table>
      <div style="width:500px; height:500px; flow:auto">
        <h2>Sources for selected author</h2>
        <pre>{{ sources }}</pre>
      </div>
    </div>
  </div>
</template>
<script>

  import RowComponents from './author_row_component'

  export default {
    components: {
      RowComponents
    },
    props: {
      list: {
        type: Array,
        required: true
      }
    },
    data() {
      return {
        author: [],
        sources: ''
      }
    },
    watch: {
      list() {
        this.sources = ''
      }
    },
    methods: {
      getSources(author_id) {
        this.$http.get("/sources.json?author_ids[]=" + author_id).then(response => {
          this.sources = response.body;
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

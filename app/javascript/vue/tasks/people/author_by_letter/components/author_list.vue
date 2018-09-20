<template>
  <div>
    <table>
      <tr>
        <th>Author</th>
        <!--<th>Object</th>-->
        <th>Radial</th>
        <!--<th>Otu</th>-->
        <th>Delete</th>
      </tr>
      <row-components
          v-for="item in list"
          @delete="removeCitation"
          :author="item"/>
      />
    </table>
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
    methods: {
      removeCitation(citation) {
        let index = this.list.findIndex((item) => {
          return citation.id == item.id
        })
        if (index > -1) {
          this.list.splice(index, 1)
        }
      },
      sortByPages() {
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

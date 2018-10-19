<template>
  <div class="flex-separate">
    <table id="source-table">
      <tr>
        <th>Source</th>
        <th/>
        <th/>
        <th/>
      </tr>
      <source-row-component
        v-for="src in list"
        :key="src.id"
        :source="src"/>
    </table>
  </div>
</template>
<script>
  import SourceRowComponent from './source_row_component'
  import Spinner from 'components/spinner.vue'

  export default {
    components: {
      SourceRowComponent,
      Spinner
    },
    props: {
      list: {
        type: Array,
        required: true
      },
    },
    methods: {
      removeAuthor(author) {
        let index = this.list.findIndex((item) => {
          return author.id == item.id
        });
        if (index > -1) {
          this.list.splice(index, 1)
        }
      },
    }
  }
</script>

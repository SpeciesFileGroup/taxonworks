<template>
  <div class="flex-separate">
    <div>
      <table>
        <tr>
          <th>Author</th>
          <th>Sources</th>
          <th>Id</th>
          <th>Uniquify</th>
          <th></th>
        </tr>
        <author-row-component
          v-for="item in list"
          :key="item.id"
          @delete="removeAuthor"
          @sources="$emit('selected', item.id)"
          :author="item"/>
      </table>
    </div>
  </div>
</template>
<script>

  import AuthorRowComponent from './author_row_component'
  import SourceRowComponent from './source_row_component'

  export default {
    components: {
      AuthorRowComponent,
      SourceRowComponent,
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

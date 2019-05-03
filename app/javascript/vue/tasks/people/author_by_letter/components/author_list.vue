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
          :class="{ highlight: selected == item.id }"
          v-for="item in list"
          :key="item.id"
          @delete="removeAuthor"
          @sources="selectAuthorSources(item.id)"
          :author="item"/>
      </table>
    </div>
  </div>
</template>
<script>

  import AuthorRowComponent from './author_row_component'

  export default {
    components: {
      AuthorRowComponent
    },
    props: {
      list: {
        type: Array,
        required: true
      },
      pagination: {
        type: Object,
      }
    },
    data() {
      return {
        selected: undefined
      }
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
      selectAuthorSources(id) {
        this.$emit('selected', id)
        this.selected = id
      }
    }
  }
</script>
<style scoped>
  .highlight {
    background-color: #E3E8E3;
  }
</style>

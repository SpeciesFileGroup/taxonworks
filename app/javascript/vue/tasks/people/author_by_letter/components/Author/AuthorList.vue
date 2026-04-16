<template>
  <div class="flex-separate">
    <div>
      <table class="table-striped">
        <thead>
          <tr>
            <th>Author</th>
            <th v-help.table.column.sources>Sources</th>
            <th>Id</th>
            <th v-help.table.column.unify>Unify</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <template
            v-for="item in list"
            :key="item.id"
          >
            <AuthorRow
              :author="item"
              v-model="selectedIds"
              @sources="selectAuthorSources(item.id)"
            />
          </template>
        </tbody>
      </table>
    </div>
  </div>
</template>
<script setup>
import { ref } from 'vue'
import AuthorRow from './AuthorRow'

defineProps({
  list: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['selected'])
const selectedIds = ref([])

function selectAuthorSources(id) {
  emit('selected', id)
}
</script>
<style scoped>
.highlight {
  border: 2px solid red;
  background-color: #e3e8e3;
}
</style>

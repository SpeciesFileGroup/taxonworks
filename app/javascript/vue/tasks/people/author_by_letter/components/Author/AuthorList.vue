<template>
  <div class="flex-separate">
    <div>
      <table>
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
              :class="{ highlight: selected == item.id }"
              :author="item"
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
const selected = ref()

function selectAuthorSources(id) {
  emit('selected', id)
}
</script>
<style scoped>
.highlight {
  background-color: #e3e8e3;
}
</style>

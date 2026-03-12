<template>
  <table v-if="t == 'new'">
    <draggable
      class="table-entrys-list"
      tag="tbody"
      item-key="id"
      v-model="list"
      @end="(event) => emit('sort', event)"
    >
      <template #item="{ element }">
        <tr>
          <RelationshipsTableRow
            :t="t"
            :element="element"
            @remove="() => emit('remove', element)"
          />
        </tr>
      </template>
    </draggable>
  </table>

  <table v-else>
    <tr v-for="element in list">
      <RelationshipsTableRow
        :t="t"
        :element="element"
        @remove="() => emit('remove', element)"
      />
    </tr>
  </table>
</template>

<script setup>
import Draggable from 'vuedraggable'
import RelationshipsTableRow from './relationshipsTableRow.vue'

const props = defineProps({
  t: {
    type: String,
    required: true,
    validator: value => ['new', 'old'].includes(value)
  }
})

const list = defineModel({
  type: Array,
  required: true
})

const emit = defineEmits(['sort', 'remove'])

</script>

<style lang="css" scoped>
td {
  vertical-align: middle;
}

.radials {
  align-items: center;
}
</style>
<template>
  <table class="table-striped">
    <thead>
      <th>Identifier</th>
      <th>Type</th>
      <th />
    </thead>
    <VDraggable
      class="table-entrys-list"
      tag="tbody"
      item-key="id"
      v-model="list"
      @end="updatePosition"
    >
      <template #item="{ element }">
        <tr class="cursor-grab">
          <td v-html="element.cached"></td>
          <td v-text="element.type" />
          <td>
            <div class="horizontal-right-content">
              <VBtn
                circle
                color="destroy"
                @click="() => deleteItem(element)"
              >
                <VIcon
                  x-small
                  name="trash"
                />
              </VBtn>
            </div>
          </td>
        </tr>
      </template>
    </VDraggable>
  </table>
</template>

<script setup>
import { Identifier } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VDraggable from 'vuedraggable'

const list = defineModel({
  type: Array,
  default: () => []
})

const emit = defineEmits(['edit', 'delete'])

function updatePosition() {
  if (list.value.length > 1) {
    const id = list.value.map((item) => item.id)

    Identifier.reorder({ id }).catch(() => {})
  }
}

function deleteItem(item) {
  if (
    window.confirm(
      `You're trying to delete this record. Are you sure want to proceed?`
    )
  ) {
    emit('delete', item)
  }
}
</script>

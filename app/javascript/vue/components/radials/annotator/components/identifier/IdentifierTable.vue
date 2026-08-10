<template>
  <table class="table-striped">
    <thead>
      <tr>
        <th class="w-4" />
        <th>Identifier</th>
        <th>Type</th>
        <th />
      </tr>
    </thead>
    <VDraggable
      class="table-entrys-list"
      tag="tbody"
      handle=".handle"
      item-key="id"
      v-model="list"
      @end="updatePosition"
    >
      <template #item="{ element }">
        <tr>
          <td>
            <DragHandle
              color="create"
              label="identifier"
            />
          </td>
          <td v-html="element.cached"></td>
          <td v-text="element.type" />
          <td>
            <div class="horizontal-right-content gap-small">
              <VBtn
                icon
                variant="tonal"
                color="destroy"
                @click="() => deleteItem(element)"
              >
                <IconTrash class="w-4 h-4" />
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
import DragHandle from '@/components/ui/DragHandle/DragHandle.vue'
import IconTrash from '@/components/Icon/IconTrash.vue'
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
      `You're trying to delete this record. Are you sure you want to proceed?`
    )
  ) {
    emit('delete', item)
  }
}
</script>

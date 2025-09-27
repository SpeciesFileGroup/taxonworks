<template>
  <table>
    <draggable
      class="table-entrys-list"
      tag="tbody"
      item-key="id"
      v-model="list"
      @end="(sortable) => emit('sort', sortable)"
    >
      <template #item="{ element }">
        <tr>
          <td v-html="element[`${t}_object_object_tag`]" />
          <td>{{ element[`${t}_object_type`] }}</td>
          <td>
            <div class="horizontal-right-content gap-small radials">
              <RadialAnnotator
                :global-id="element[`${t}_object_global_id`]"
              />
              <span
                class="circle-button btn-delete"
                @click="(element) => emit('remove', element)"
              />
            </div>
          </td>
        </tr>
      </template>
    </draggable>
  </table>
</template>

<script setup>
import Draggable from 'vuedraggable'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'

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
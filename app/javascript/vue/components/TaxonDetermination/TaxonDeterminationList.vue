<template>
  <table class="vue-table">
    <thead>
      <tr>
        <th>
          Determination
        </th>
        <th>
          <div class="horizontal-right-content">
            <lock-component
              class="margin-small-left"
              v-model="locked.taxonDeterminations"/>
          </div>
        </th>
      </tr>
    </thead>
    <draggable
      class="table-entrys-list"
      tag="tbody"
      :item-key="item => item"
      v-model="list"
      @end="updatePosition">
      <template #item="{ element }">
        <tr>
          <td>
            <a
              v-if="element.id"
              v-html="element.object_tag"
              :href="`${RouteNames.BrowseOtu}?otu_id=${element.otu_id}`"/>
            <span
              v-else
              v-html="element.object_tag"/>
          </td>
          <td>
            <div class="horizontal-right-content">
              <span
                v-if="element.id"
                @click="emit('onEdit', element)"
                class="button circle-button btn-edit"/>
              <radial-annotator
                v-if="element.global_id"
                :global-id="element.global_id"/>
              <span
                class="circle-button btn-delete"
                :class="{ 'button-default': !element.id }"
                @click="emit('onDelete', element)"/>
            </div>
          </td>
        </tr>
      </template>
    </draggable>
  </table>
</template>

<script setup>

import { computed } from 'vue'
import { RouteNames } from 'routes/routes'
import Draggable from 'vuedraggable'

const props = defineProps({
  list: Array
})

const emit = defineEmits([
  'update:modelValue',
  'onEdit',
  'onDelete'
])

const determinationList = computed({
  get: () => props.list,
  set: (value) => { emit('update:modelValue', value) }
})


const updatePosition = () => {
  for (let i = 0; i < determinationList.value.length; i++) {
    determinationList.value[i].position = (i + 1)
  }
}

</script>

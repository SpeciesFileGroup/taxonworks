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
              v-if="lock !== undefined"
              class="margin-small-left"
              v-model="lockButton"
            />
          </div>
        </th>
      </tr>
    </thead>
    <draggable
      class="table-entrys-list"
      tag="tbody"
      :item-key="item => item"
      v-model="determinationList"
      @end="updatePosition"
    >
      <template #item="{ element }">
        <tr>
          <td>
            <div class="padding-small-top">
              <a
                v-if="element.id"
                v-html="element.object_tag"
                :href="`${RouteNames.BrowseOtu}?otu_id=${element.otu_id}`"
              />
              <span
                v-else
                v-html="element.object_tag"
              />
            </div>
          </td>
          <td>
            <div class="horizontal-right-content">
              <radial-annotator
                v-if="element.global_id"
                :global-id="element.global_id"
              />

              <v-btn
                class="margin-small-right"
                circle
                :color="element.id ? 'update' : 'primary'"
                @click="emit('edit', element)"
              >
                <v-icon
                  x-small
                  name="pencil"
                />
              </v-btn>

              <v-btn
                circle
                :color="element.id ? 'destroy' : 'primary'"
                @click="emit('delete', element)"
              >
                <v-icon
                  x-small
                  name="trash"
                />
              </v-btn>
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
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import LockComponent from 'components/ui/VLock/index.vue'
import Draggable from 'vuedraggable'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

const props = defineProps({
  modelValue: {
    type: Array,
    default: () => []
  },

  lock: {
    type: Boolean,
    default: undefined
  }
})

const emit = defineEmits([
  'update:modelValue',
  'update:lock',
  'edit',
  'delete'
])

const lockButton = computed({
  get: () => props.lock,
  set: value => emit('update:lock', value)
})

const determinationList = computed({
  get: () => props.modelValue,
  set: (value) => { emit('update:modelValue', value) }
})

const updatePosition = () => {
  for (let i = 0; i < determinationList.value.length; i++) {
    determinationList.value[i].position = (i + 1)
  }
}

</script>

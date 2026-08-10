<template>
  <table class="vue-table table-striped">
    <thead>
      <tr>
        <th>Determination</th>
        <th>
          <div class="horizontal-right-content">
            <VLock
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
      :item-key="(item) => item"
      handle=".handle"
      v-model="determinationList"
      @end="updatePosition"
    >
      <template #item="{ element }">
        <tr>
          <td>
            <div class="flex flex-row middle gap-small">
              <DragHandle
                color="create"
                label="taxon determination"
              />

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
            <div class="horizontal-right-content gap-small">
              <RadialAnnotator
                v-if="element.global_id"
                :global-id="element.global_id"
              />

              <VBtn
                color="primary"
                icon
                variant="tonal"
                @click="emit('edit', element)"
              >
                <IconPencil class="w-4 h-4" />
              </VBtn>

              <VBtn
                icon
                :color="element.id ? 'destroy' : 'primary'"
                variant="tonal"
                @click="emit('delete', element)"
              >
                <IconTrash class="w-4 h-4" />
              </VBtn>
            </div>
          </td>
        </tr>
      </template>
    </draggable>
  </table>
</template>

<script setup>
import { computed } from 'vue'
import { RouteNames } from '@/routes/routes'
import { TaxonDetermination } from '@/routes/endpoints'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import VLock from '@/components/ui/VLock/index.vue'
import Draggable from 'vuedraggable'
import VBtn from '@/components/ui/VBtn/index.vue'
import DragHandle from '@/components/ui/DragHandle/DragHandle.vue'
import IconPencil from '@/components/Icon/IconPencil.vue'
import IconTrash from '@/components/Icon/IconTrash.vue'

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
  'delete',
  'sort'
])

const lockButton = computed({
  get: () => props.lock,
  set: (value) => emit('update:lock', value)
})

const determinationList = computed({
  get: () => props.modelValue,
  set: (value) => {
    emit('update:modelValue', value)
  }
})

function updatePosition() {
  const id = determinationList.value.map((item) => item.id).filter(Boolean)

  if (id.length) {
    TaxonDetermination.reorder({ id }).then(({ body }) => {
      emit('sort', body)
    })
  }
}
</script>

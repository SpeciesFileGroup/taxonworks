<template>
  <HandyScroll>
    <table
      class="full_width table-striped"
      v-resize-column
      ref="root"
    >
      <thead>
        <tr>
          <th class="w-2">
            <input
              type="checkbox"
              v-model="selectAll"
            />
          </th>
          <th class="w-2" />
          <th>Name</th>
          <th>Object tag</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in list"
          :key="item.id"
          class="contextMenuCells"
        >
          <td>
            <input
              type="checkbox"
              v-model="soundIds"
              :value="item.id"
            />
          </td>
          <td>
            <div class="horizontal-right-content middle gap-small">
              <RadialAnnotator :global-id="item.global_id" />
              <RadialNavigator :global-id="item.global_id" />
            </div>
          </td>
          <td>{{ item.name }}</td>
          <td v-html="item.object_tag" />
          <td>
            <audio
              v-if="!item.metadata.error"
              :src="item.sound_file"
              controls
              preload="metadata"
            />
            <div v-else>
              <div style="color: red">
                {{ item.metadata.error }}
              </div>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </HandyScroll>
</template>

<script setup>
import { computed, watch, useTemplateRef } from 'vue'
import { vResizeColumn } from '@/directives'
import HandyScroll from 'vue-handy-scroll'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:modelValue'])

const soundIds = defineModel({
  type: Array,
  default: () => []
})
const element = useTemplateRef('root')

const selectAll = computed({
  get: () =>
    props.list.length === props.modelValue.length && props.list.length > 0,
  set: (value) =>
    emit('update:modelValue', value ? props.list.map((item) => item.id) : [])
})

watch(
  () => props.list,
  () => {
    HandyScroll.EventBus.emit('update', { sourceElement: element.value })
  },
  { immediate: true }
)
</script>

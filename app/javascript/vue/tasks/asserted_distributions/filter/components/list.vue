<template>
  <HandyScroll>
    <div ref="element">
      <table
        class="full_width table-striped"
        v-resize-column
      >
        <thead>
          <tr>
            <th class="w-2">
              <input
                v-model="selectIds"
                type="checkbox"
              >
            </th>
            <th class="w-2" />
            <th
              v-for="rank in RANKS"
              :key="rank"
              class="capitalize"
              v-text="rank"
            />
            <th>OTU</th>
            <th>Geographic area</th>
            <th>Citations</th>
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
                v-model="ids"
                :value="item.id"
                type="checkbox"
              >
            </td>
            <td>
              <div class="horizontal-left-content">
                <RadialAnnotator :global-id="item.global_id" />
                <RadialNavigation :global-id="item.global_id" />
              </div>
            </td>
            <td
              v-for="rank in RANKS"
              :key="rank"
              v-html="parseRank(item.taxonomy[rank])"
            />
            <td v-html="item.otu.object_tag" />
            <td v-html="item.geographic_area.name" />
            <td v-html="item?.citations?.map(c => c.citation_source_body).join('; ')" />
          </tr>
        </tbody>
      </table>
    </div>
  </HandyScroll>
</template>

<script setup>
import HandyScroll from 'vue-handy-scroll'
import RadialNavigation from 'components/radials/navigation/radial.vue'
import RadialAnnotator from 'components/radials/annotator/annotator'
import { computed, ref, watch } from 'vue'
import { vResizeColumn } from 'directives/resizeColumn.js'

const RANKS = ['order', 'family', 'genus']

const props = defineProps({
  list: {
    type: Object,
    default: undefined
  },

  modelValue: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits([
  'onSort',
  'update:modelValue'
])

const element = ref(null)

const selectIds = computed({
  get: () => props.list.length === props.modelValue.length,
  set: value => emit('update:modelValue',
    value
      ? props.list.map(item => item.id)
      : []
  )
})

const ids = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

function parseRank (rank) {
  return Array.isArray(rank)
    ? rank.filter(Boolean).join(' ')
    : rank
}

watch(
  () => props.list,
  () => { HandyScroll.EventBus.emit('update', { sourceElement: element.value }) },
  { immediate: true }
)

</script>

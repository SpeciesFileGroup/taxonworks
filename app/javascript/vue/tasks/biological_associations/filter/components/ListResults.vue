<template>
  <HandyScroll>
    <div ref="element">
      <table
        class="full_width"
        v-resize-column
      >
        <thead>
          <tr>
            <td colspan="1" />
            <th
              colspan="5"
              scope="colgroup"
            >
              Subject
            </th>
            <td colspan="1" />
            <th
              colspan="5"
              scope="colgroup"
            >
              Object
            </th>
          </tr>
          <tr>
            <th>
              <input
                v-model="selectIds"
                type="checkbox"
              >
            </th>
            <th>Order</th>
            <th>Family</th>
            <th>Genus</th>
            <th>Object tag</th>
            <th>Biological properties</th>
            <th>Biological relationship</th>
            <th>Biological properties</th>
            <th>Order</th>
            <th>Family</th>
            <th>Genus</th>
            <th>Object tag</th>
            <th />
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(item, index) in list"
            :key="item.id"
            class="contextMenuCells"
            :class="{ even: index % 2 }"
          >
            <td>
              <input
                v-model="ids"
                :value="item.id"
                type="checkbox"
              >
            </td>
            <td
              v-for="rank in RANKS"
              :key="rank"
              v-html="parseRank(item.subject.taxonomy[rank])"
            />
            <td v-html="item.subject.object_tag" />
            <td v-text="getBiologicalProperty(item.biological_relationship_types, 'object')" />
            <td v-text="item.biological_relationship.object_tag" />
            <td v-text="getBiologicalProperty(item.biological_relationship_types, 'subject')" />
            <td
              v-for="rank in RANKS"
              :key="rank"
              v-html="parseRank(item.object.taxonomy[rank])"
            />
            <td v-html="item.object.object_tag" />
            <td>
              <div class="horizontal-right-content">
                <RadialAnnotator
                  :global-id="item.global_id"
                />
                <RadialNavigation
                  :global-id="item.global_id"
                />
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </HandyScroll>
</template>

<script setup>

import { computed, ref, watch } from 'vue'
import { sortArray } from 'helpers/arrays.js'
import HandyScroll from 'vue-handy-scroll'
import { vResizeColumn } from 'directives/resizeColumn.js'
import RadialNavigation from 'components/radials/navigation/radial.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'

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

watch(
  () => props.list,
  () => { HandyScroll.EventBus.emit('update', { sourceElement: element.value }) },
  { immediate: true }
)

const ascending = ref(false)

const sortTable = sortProperty => {
  emit('onSort', sortArray(this.list, sortProperty, ascending.value))
  ascending.value = !ascending.value
}

const getBiologicalProperty = (biologicalRelationshipTypes, type) =>
  biologicalRelationshipTypes.find(r => r.target === type)?.biological_property?.name

const parseRank = rank => {
  return Array.isArray(rank)
    ? rank.filter(Boolean).join(' ')
    : rank
}

</script>

<style lang="scss" scoped>

  tr {
    height: 44px;
  }
  .options-column {
    width: 130px;
  }
  .overflow-scroll {
    overflow: scroll;
  }

</style>

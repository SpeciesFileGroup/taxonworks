<template>
  <div
    v-if="list.length"
    class="full_width table-striped"
  >
    <table class="full_width">
      <thead>
        <tr>
          <th class="w-2">
            <input
              type="checkbox"
              v-model="toggleIds"
            >
          </th>
          <th class="w-2" />
          <th
            v-for="rank in RANKS"
            :key="rank"
            v-text="rank"
          />
          <th>OTU</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="otu in list"
          class="contextMenuCells"
          :key="otu.id"
        >
          <td>
            <input
              :value="otu.id"
              v-model="ids"
              type="checkbox"
            >
          </td>
          <td>
            <div class="horizontal-right-content">
              <RadialAnnotator :global-id="otu.global_id" />
              <RadialObject :global-id="otu.global_id" />
              <RadialNavigation :global-id="otu.global_id" />
            </div>
          </td>
          <td
            v-for="rank in RANKS"
            :key="rank"
            v-html="parseRank(otu.taxonomy[rank])"
          />
          <td v-html="otu.object_tag" />
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import RadialAnnotator from 'components/radials/annotator/annotator'
import RadialObject from 'components/radials/object/radial'
import RadialNavigation from 'components/radials/navigation/radial.vue'
import { computed } from 'vue'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  },

  modelValue: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:modelValue'])

const ids = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const toggleIds = computed({
  get: () => props.list.length === props.modelValue.length,
  set: value => emit('update:modelValue',
    value
      ? props.list.map(item => item.id)
      : []
  )
})

const RANKS = ['order', 'family', 'genus']

function parseRank (rank) {
  return Array.isArray(rank)
    ? rank.filter(Boolean).join(' ')
    : rank
}

</script>

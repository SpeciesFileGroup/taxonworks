<template>
  <div class="full_width">
    <table class="full_width">
      <thead>
        <tr>
          <th
            :class="() => classSort('object_tag')"
            @click="() => sortTable('object_tag')"
          >
            Object tag
          </th>
          <th>Citations</th>
          <th>Options</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in list"
          :key="item.id"
        >
          <td>
            <span v-html="item.object_tag" />
          </td>
          <td>
            <template
              v-for="citation in item.citations"
              :key="citation.id"
            >
              <span>{{ citation.citation_source_body }};</span>
            </template>
          </td>
          <td class="options-column">
            <div class="horizontal-left-content">
              <RadialNavigator
                :global-id="item.global_id"
              />
              <RadialAnnotator
                type="annotations"
                :global-id="item.global_id"
              />
            </div>
          </td>
        </tr>
      </tbody>
    </table>
    <span
      v-if="list.length"
      class="horizontal-left-content"
      >{{ list.length }} records.
    </span>
  </div>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator'
import RadialNavigator from '@/components/radials/navigation/radial'
import { ref } from 'vue'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  }
})

const sortColumns = ref({
  name: undefined,
  verbatim_author: undefined,
  year_of_publication: undefined,
  rank: undefined,
  original_combination: undefined
})

function sortTable(sortProperty) {
  function compare(a, b) {
    if (a[sortProperty] < b[sortProperty])
      return sortColumns.value[sortProperty] ? -1 : 1
    if (a[sortProperty] > b[sortProperty])
      return sortColumns.value[sortProperty] ? 1 : -1
    return 0
  }

  if (sortColumns.value[sortProperty] == undefined) {
    sortColumns.value[sortProperty] = true
  } else {
    sortColumns.value[sortProperty] = !sortColumns.value[sortProperty]
  }
  props.list.sort(compare)
}

function classSort(value) {
  if (sortColumns.value[value] == true) {
    return 'headerSortDown'
  }
  if (sortColumns.value[value] == false) {
    return 'headerSortUp'
  }
  return ''
}
</script>

<style lang="scss" scoped>
table {
  margin-top: 0px;
}
tr {
  height: 44px;
}
.options-column {
  width: 130px;
}
</style>

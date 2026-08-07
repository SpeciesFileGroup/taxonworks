<template>
  <div>
    <table
      class="full_width table-striped"
      v-if="list.length"
    >
      <thead>
        <tr>
          <th class="w-2" />
          <th>Biological assocations</th>
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
            <RadialNavigator :global-id="item.global_id" />
          </td>
          <td v-html="item.object_tag" />
        </tr>
      </tbody>
    </table>
    <i v-else>None</i>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { BiologicalAssociation } from '@/routes/endpoints'
import { extend } from '../constants/extend.js'
import RadialNavigator from '@/components/radials/navigation/radial.vue'

const props = defineProps({
  biologicalRelationship: {
    type: Object,
    default: undefined
  },
  subjectString: {
    type: String,
    default: undefined
  },
  objectString: {
    type: String,
    default: undefined
  }
})

const list = ref([])

watch(
  () => props.biologicalRelationship,
  (newVal) => {
    if (newVal) {
      BiologicalAssociation.where({
        biological_relationship_id: newVal.id,
        per: 10,
        extend: [...extend, 'bioloical_relationship']
      }).then((response) => {
        list.value = response.body
      })
    } else {
      list.value = []
    }
  }
)
</script>

<style scoped>
td {
  line-height: 1.75rem;
}
</style>

<template>
  <div class="full_width">
    <table class="full_width">
      <thead>
        <tr>
          <th class="w-2" />
          <th>
            <div class="gap-small">
              Object tag
              <VBtn
                color="primary"
                circle
                @click="sortColumn('object_tag')"
              >
                <VIcon
                  name="alphabeticalSort"
                  x-small
                />
              </VBtn>
            </div>
          </th>
          <th @click="sortColumn('object_tag')">Citations</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in list"
          :key="item.id"
        >
          <td>
            <div class="horizontal-right-content gap-small">
              <RadialAnnotator
                type="annotations"
                :global-id="item.global_id"
              />
              <RadialObject :global-id="item.global_id" />
            </div>
          </td>
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
import RadialObject from '@/components/radials/navigation/radial'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { sortArray } from '@/helpers'
import { ref } from 'vue'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['sort'])
const ascending = ref(false)

function sortColumn(attr) {
  emit(
    'sort',
    sortArray(props.list, attr, ascending.value, { stripHtml: true })
  )

  ascending.value = !ascending.value
}
</script>

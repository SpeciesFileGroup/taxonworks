<template>
  <SectionPanel
    :title="title"
    :status="status"
    :spinner="loadState.fieldOccurrences"
  >
    <ul class="no_bullets">
      <li
        v-for="fieldOccurrence in fieldOccurrences"
        :key="fieldOccurrence.id"
      >
        <FieldOccurrenceRow :field-occurrence="fieldOccurrence" />
      </li>
    </ul>
  </SectionPanel>
</template>

<script setup>
import SectionPanel from '../shared/sectionPanel'
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters'
import FieldOccurrenceRow from './FieldOccurrenceRow.vue'

const props = defineProps({
  status: {
    type: String,
    default: 'unknown'
  },

  title: {
    type: String,
    default: undefined
  },

  otu: {
    type: Object,
    required: true
  }
})

const store = useStore()
const loadState = computed(() => store.getters[GetterNames.GetLoadState])
const fieldOccurrences = computed(
  () => store.getters[GetterNames.GetFieldOccurrences]
)
</script>

<template>
  <FacetContainer>
    <h3>Collecting Event</h3>
    <div class="field">
      <smart-selector
        model="collecting_events"
        klass="CollectionObject"
        pin-section="CollectingEvents"
        pin-type="CollectingEvent"
        @selected="addCe"
      />
      <ul class="no_bullets table-entrys-list">
        <li
          class="middle flex-separate list-complete-item"
          v-for="(ce, index) in collectingEvents"
          :key="ce.id"
        >
          <span v-html="ce.object_tag" />
          <span
            class="btn-delete button-circle"
            @click="removeCe(index)"
          />
        </li>
      </ul>
    </div>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import { computed, watch, ref, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { CollectingEvent } from 'routes/endpoints'
import SmartSelector from 'components/ui/SmartSelector'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])
const collectingEvents = ref([])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

watch(
  collectingEvents,
  (newVal) => {
    params.value.collecting_event_id = newVal.map((ce) => ce.id)
  },
  { deep: true }
)

watch(
  () => props.modelValue.collecting_event_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      collectingEvents.value = []
    }
  }
)

function addCe(ce) {
  if (params.value?.collecting_event_id?.includes(ce.id)) return

  collectingEvents.value.push(ce)
}

function removeCe(index) {
  collectingEvents.value.splice(index, 1)
}

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  if (urlParams.collecting_event_id) {
    urlParams.collecting_event_id.forEach((id) => {
      CollectingEvent.find(id).then((response) => {
        addCe(response.body)
      })
    })
  }
})
</script>
<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>

<template>
  <div>
    <h3>Collecting Event</h3>
    <div class="field">
      <h4>Select collecting events</h4>
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
  </div>
</template>

<script setup>
import { computed, watch, ref } from 'vue'
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

const collectingEventIds = computed({
  get () {
    return props.modelValue
  },
  set (value) {
    emit('update:modelValue', value)
  }
})

watch(
  collectingEventIds,
  newVal => {
    if (!newVal.length) {
      collectingEvents.value = []
    }
  }
)

function addCe (ce) {
  if (collectingEventIds.value.includes(ce.id)) return
  collectingEventIds.value.push(ce.id)
  collectingEvents.value.push(ce)
}

function removeCe (index) {
  collectingEventIds.value.splice(index, 1)
  collectingEvents.value.splice(index, 1)
}

const urlParams = URLParamsToJSON(location.href)

if (urlParams.collecting_event_ids) {
  urlParams.collecting_event_ids.forEach(id => {
    CollectingEvent.find(id).then(response => {
      addCe(response.body)
    })
  })
}
</script>
<style scoped>
  :deep(.vue-autocomplete-input) {
    width: 100%
  }
</style>

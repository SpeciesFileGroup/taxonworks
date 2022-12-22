<template>
  <div>
    <h3>Collecting Event</h3>
    <h4>Date range</h4>
    <div class="horizontal-left-content">
      <div class="field separate-right">
        <label>Start date</label>
        <br>
        <input
          type="date"
          v-model="params.start_date"
        >
      </div>

      <div class="field">
        <label>End date</label>
        <br>
        <input
          type="date"
          v-model="params.end_date"
        >
      </div>
    </div>
    <div class="field">
      <label>
        <input
          type="checkbox"
          v-model="params.partial_overlap_dates"
        >
        Allow partial overlaps
      </label>
    </div>
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
    <add-field
      ref="addFieldRef"
      :list="params.fields"
      @fields="setFields"
    />
  </div>
</template>

<script setup>
import { ref, computed, watch, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import SmartSelector from 'components/ui/SmartSelector'
import AddField from './addFields'
import { CollectingEvent } from 'routes/endpoints'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])
const addFieldRef = ref(null)

const params = computed({
  get () {
    return props.modelValue
  },
  set (value) {
    emit('update:modelValue', value)
  }
})

watch(
  params,
  newVal => {
    if (!newVal.fields) {
      addFieldRef.value.fields?.cleanList()
    }
  }
)

const collectingEvents = ref([])

watch(
  collectingEvents,
  newVal => {
    params.value.collecting_event_ids = newVal.map(ce => ce.id)
  }
)

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  if (urlParams.collecting_event_ids) {
    urlParams.collecting_event_ids.forEach(id => {
      CollectingEvent.find(id).then(response => {
        addCe(response.body)
      })
    })
  }

  params.value.start_date = urlParams.start_date
  params.value.end_date = urlParams.end_date
  params.value.partial_overlap_dates = urlParams.partial_overlap_dates
})

const addCe = (ce) => {
  collectingEvents.value.push(ce)
}

const removeCe = (index) => {
  collectingEvents.value.splice(index, 1)
}

const setFields = (fields) => {
  params.value = {
    ...params.value,
    ...fields
  }
}

</script>
<style scoped>
  :deep(.vue-autocomplete-input) {
    width: 100%
  }
</style>

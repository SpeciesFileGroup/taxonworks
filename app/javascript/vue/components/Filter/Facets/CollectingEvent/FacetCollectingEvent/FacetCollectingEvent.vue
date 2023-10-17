<template>
  <FacetContainer>
    <h3>Collecting Event</h3>
    <h4>Date range</h4>
    <div class="horizontal-left-content">
      <div class="field separate-right">
        <label>Start date</label>
        <br />
        <input
          type="date"
          v-model="params.start_date"
        />
      </div>

      <div class="field">
        <label>End date</label>
        <br />
        <input
          type="date"
          v-model="params.end_date"
        />
      </div>
    </div>
    <div class="field">
      <label>
        <input
          type="checkbox"
          v-model="params.partial_overlap_dates"
        />
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
    <ByAttribute
      controller="collecting_events"
      v-model="params"
    />
  </FacetContainer>
</template>

<script setup>
import { ref, computed, watch, onBeforeMount } from 'vue'
import { CollectingEvent } from '@/routes/endpoints'
import SmartSelector from '@/components/ui/SmartSelector'
import ByAttribute from '../../shared/ByAttribute.vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get() {
    return props.modelValue
  },
  set(value) {
    emit('update:modelValue', value)
  }
})

const collectingEvents = ref([])

watch(
  collectingEvents,
  (newVal) => {
    params.value.collecting_event_id = newVal.map((ce) => ce.id)
  },
  {
    deep: true
  }
)

watch(
  () => props.modelValue.collecting_event_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      collectingEvents.value = []
    }
  },
  {
    deep: true
  }
)

onBeforeMount(() => {
  const idParam = params.value?.collecting_event_id
  const ids = idParam && [idParam].flat()

  if (ids) {
    ids.forEach((id) => {
      CollectingEvent.find(id).then((response) => {
        addCe(response.body)
      })
    })
  }
})

const addCe = (ce) => {
  collectingEvents.value.push(ce)
}

const removeCe = (index) => {
  collectingEvents.value.splice(index, 1)
}
</script>

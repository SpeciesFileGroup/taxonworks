<template>
  <FacetContainer>
    <h3>Serials</h3>
    <fieldset>
      <legend>Serials</legend>
      <SmartSelector
        model="serials"
        klass="Source"
        target="Source"
        @selected="addSerial"
      />
    </fieldset>
    <DisplayList
      :list="serials"
      label="object_tag"
      :delete-warning="false"
      @delete-index="removeSerial"
    />
  </FacetContainer>
</template>

<script setup>
import SmartSelector from 'components/ui/SmartSelector'
import DisplayList from 'components/displayList'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import { Serial } from 'routes/endpoints'
import { computed, ref, watch, onMounted } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
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

const serials = ref([])

watch(
  () => props.modelValue.serial_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      serials.value = []
    }
  }
)

watch(
  serials,
  (newVal) => {
    params.value.serial_id = newVal.map((item) => item.id)
  },
  { deep: true }
)

function addSerial(serial) {
  if (!serials.value.some(s => s.id === serial.id)) {
    serials.value.push(serial)
  }
}

function removeSerial(index) {
  serials.value.splice(index, 1)
}

onMounted(() => {
  params.value.serial_id?.forEach((id) => {
    Serial.find(id).then((response) => {
      addSerial(response.body)
    })
  })
})
</script>

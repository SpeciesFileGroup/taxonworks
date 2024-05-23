<template>
  <FacetContainer>
    <h3>Determinations</h3>
    <div class="field">
      <h4>Otu</h4>
      <autocomplete
        url="/otus/autocomplete"
        placeholder="Select an otu"
        param="term"
        label="label_html"
        clear-after
        display="label"
        @get-item="addOtu($event.id)"
      />
    </div>
    <div class="field separate-top">
      <ul class="no_bullets table-entrys-list">
        <li
          class="middle flex-separate list-complete-item"
          v-for="(otu, index) in otus"
          :key="otu.id"
        >
          <span v-html="otu.object_tag" />
          <VBtn
            circle
            color="primary"
            @click="removeOtu(index)"
          >
            <VIcon
              name="trash"
              x-small
            />
          </VBtn>
        </li>
      </ul>
    </div>
    <div class="field">
      <FacetPeople
        class="no-shadow no-padding"
        v-model="params"
        role="Determiner"
        title="Determiner"
        klass="CollectionObject"
        param-people="determiner_id"
        param-any="determiner_id_or"
        :role-type="DETERMINER_SELECTOR"
        toggle
        @toggle="
          ($event) => {
            isCurrentDeterminationVisible = $event
          }
        "
      />
    </div>

    <div
      v-if="isCurrentDeterminationVisible"
      class="field"
    >
      <ul class="no_bullets">
        <li
          v-for="item in CURRENT_DETERMINATION_OPTIONS"
          :key="item.value"
        >
          <label>
            <input
              type="radio"
              :value="item.value"
              name="current-determination"
              v-model="params.current_determinations"
            />
            {{ item.label }}
          </label>
        </li>
      </ul>
    </div>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import Autocomplete from '@/components/ui/Autocomplete'
import FacetPeople from '../../shared/FacetPeople.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { DETERMINER_SELECTOR } from '@/constants/index.js'
import { Otu } from '@/routes/endpoints'
import { ref, computed, watch, onBeforeMount } from 'vue'

const CURRENT_DETERMINATION_OPTIONS = [
  {
    label: 'Current and historical',
    value: undefined
  },
  {
    label: 'Current only',
    value: true
  },
  {
    label: 'Historical only',
    value: false
  }
]

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const otus = ref([])
const isCurrentDeterminationVisible = ref(true)

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

watch(
  otus,
  (newVal) => {
    params.value.otu_id = newVal.map((otu) => otu.id)
  },
  { deep: true }
)

watch(
  () => props.modelValue.otu_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      otus.value = []
    }
  },
  { deep: true }
)

watch(isCurrentDeterminationVisible, () => {
  params.value.current_determinations = undefined
})

onBeforeMount(() => {
  const { otu_id = [] } = props.modelValue

  otu_id.forEach((id) => {
    addOtu(id)
  })
})

function addOtu(id) {
  Otu.find(id).then((response) => {
    otus.value.push(response.body)
  })
}

function removeOtu(index) {
  otus.value.splice(index, 1)
}
</script>

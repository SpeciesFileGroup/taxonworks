<template>
  <FacetContainer>
    <h3>Nomenclature rank</h3>
    <ul class="no_bullets">
      <li
        v-for="option in OPTIONS"
        :key="option.value"
      >
        <label>
          <input
            :value="option.value"
            v-model="params.nomenclature_group"
            type="radio"
          >
          {{ option.label }}
        </label>
      </li>
    </ul>

    <div class="field label-above margin-medium-top">
      <label>Ranks</label>
      <select @change="addToArray(selectedRanks, rankList[$event.target.value], 'rankClass')">
        <option
          disabled
          selected
        >
          Select rank
        </option>
        <option
          v-for="(rank, index) in rankList"
          :key="rank.rankClass"
          :value="index"
        >
          {{ rank.name }}
        </option>
      </select>
    </div>

    <DisplayList
      :list="selectedRanks"
      :delete-warning="false"
      label="name"
      soft-delete
      @delete="removeFromArray(selectedRanks, $event, 'rankClass')"
    />
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import { TaxonName } from 'routes/endpoints'
import { computed, onBeforeMount, ref, watch } from 'vue'
import DisplayList from 'components/displayList.vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { removeFromArray, addToArray } from 'helpers/arrays'

const OPTIONS = [
  {
    label: 'Any rank',
    value: undefined
  },
  {
    label: 'Higher',
    value: 'Higher'
  },
  {
    label: 'Family group',
    value: 'Family'
  },
  {
    label: 'Genus group',
    value: 'Genus'
  },
  {
    label: 'Species group',
    value: 'Species'
  }
]

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const selectedRanks = ref([])

const ranks = ref({})

const rankList = computed(() => {
  const nomenclatureCodes = Object.keys(ranks.value)
  const list = []

  nomenclatureCodes.forEach(code => {
    const groups = Object.values(ranks.value[code])

    groups.forEach(group => {
      group.forEach(item => {
        list.push({
          name: `${code.toUpperCase()} - ${item.name}`,
          rankClass: item.rank_class
        })
      })
    })
  })

  return list
})

watch(
  selectedRanks,
  newVal => {
    params.value.rank = newVal.map(rank => rank.rankClass)
  },
  { deep: true }
)

watch(
  () => props.modelValue.rank,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      selectedRanks.value = []
    }
  }
)

onBeforeMount(() => {
  params.value.nomenclature_group = URLParamsToJSON(location.href).nomenclature_group

  TaxonName.ranks().then(
    ({ body }) => { ranks.value = body }
  )
})
</script>

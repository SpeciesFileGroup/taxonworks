<template>
  <div class="panel margin-small-bottom padding-small">
    <div
      @click="isExpanded = !isExpanded"
      class="cursor-pointer inline"
    >
      <VBtn
        circle
        color="primary"
      >
        <VIcon
          :name="isExpanded ? 'arrowDown' : 'arrowRight'"
          x-small
        />
      </VBtn>
      <span class="margin-small-left">
        [<span
          v-html="
            types
              .map(
                (type) => `${type.type_type} of ${type.original_combination}`
              )
              .join('; ')
          "
        />] - <span v-html="ceLabel" />
      </span>
    </div>
    <template v-if="isExpanded">
      <TypeData
        v-for="type in types"
        :key="type.id"
        class="species-information-container"
        :type="type"
      />
      <SpecimenInformation
        v-if="isExpanded"
        class="species-information-container"
        :specimen="specimen"
      />
    </template>
  </div>
</template>

<script setup>
import SpecimenInformation from './SpecimenInformation'
import TypeData from './TypeData'
import VIcon from '@/components/ui/VIcon/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { computed, ref } from 'vue'

const LEVELS = ['country', 'stateProvince', 'county']

const props = defineProps({
  specimen: {
    type: Object,
    required: true
  },

  types: {
    type: Array,
    default: () => []
  }
})

const ceLabel = computed(() => {
  const areas = []
  const verbatimLabel = props.specimen.verbatimLocality

  LEVELS.forEach((level) => {
    const levelData = props.specimen[level]

    if (levelData) {
      areas.push(`<b>${levelData}</b>`)
    }
  })

  if (verbatimLabel) {
    areas.push(verbatimLabel)
  }

  return areas.join('; ')
})

const isExpanded = ref(false)
</script>

<style scoped>
.species-information-container {
  margin-left: 20px;
}
</style>

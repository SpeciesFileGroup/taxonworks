<template>
  <div>
    <div
      v-if="isCountExceeded"
      class="feedback feedback-danger"
    >
      Too many records selected, maximum {{ MAX_LIMIT }}
    </div>
    <div class="flex-separate">
      <div>
        <h3>Add</h3>
        <BiocurationGroup
          v-for="group in biocurationsGroups"
          :key="group.id"
          :group="group"
          :parameters="parameters"
          class="margin-small-bottom"
          color="submit"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, onBeforeMount } from 'vue'
import { ControlledVocabularyTerm, Tag } from '@/routes/endpoints'
import { BIOCURATION_CLASS, BIOCURATION_GROUP } from '@/constants'
import BiocurationGroup from './BiocurationGroup.vue'

const MAX_LIMIT = 50

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  },

  count: {
    type: Number,
    required: true
  }
})

const biocurationsGroups = ref([])
const biocutarionsType = ref([])
const isCountExceeded = computed(() => props.count > MAX_LIMIT)

onBeforeMount(() => {
  ControlledVocabularyTerm.where({ type: [BIOCURATION_GROUP] }).then(
    (response) => {
      biocurationsGroups.value = response.body
      ControlledVocabularyTerm.where({ type: [BIOCURATION_CLASS] }).then(
        (response) => {
          biocutarionsType.value = response.body
          splitGroups()
        }
      )
    }
  )
})

function splitGroups() {
  biocurationsGroups.value.forEach((item) => {
    Tag.where({ keyword_id: item.id }).then(({ body }) => {
      const tmpArray = []

      body.forEach((item) => {
        biocutarionsType.value.forEach((itemClass) => {
          if (itemClass.id === item.tag_object_id) {
            tmpArray.push(itemClass)
          }
        })
      })

      item.list = tmpArray
    })
  })
}
</script>

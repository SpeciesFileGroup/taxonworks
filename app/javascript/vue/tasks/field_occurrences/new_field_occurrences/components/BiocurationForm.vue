<template>
  <div>
    <div>
      <div v-for="group in biocurationsGroups">
        <label>{{ group.name }}</label>
        <br />
        <template
          v-for="item in group.list"
          :key="item.id"
        >
          <VBtn
            v-if="!isInList(item.id)"
            :color="biologicalId ? 'create' : 'primary'"
            class="biocuration-toggle-button"
            @click="addBiocuration(item.id)"
          >
            {{ item.name }}
          </VBtn>
          <VBtn
            v-else
            :color="biologicalId && 'destroy'"
            class="biocuration-toggle-button"
            @click="() => removeBiocuration(item)"
          >
            {{ item.name }}
          </VBtn>
        </template>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, computed } from 'vue'
import {
  BiocurationClassification,
  ControlledVocabularyTerm,
  Tag
} from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'
import {
  BIOCURATION_CLASS,
  BIOCURATION_GROUP,
  FIELD_OCCURRENCE
} from '@/constants'

const props = defineProps({
  biologicalId: {
    type: [String, Number],
    default: undefined
  },

  biocutarionsType: {
    type: Array,
    default: () => []
  },

  biocurationsGroups: {
    type: Array,
    default: () => []
  }
})

const biocurationList = ref([])
const createdBiocutarions = ref([])
const unsavedBiocurations = computed(() =>
  biocurationList.value.filter((item) => item.id)
)

watch(
  () => props.biologicalId,
  (newId, oldId) => {
    createdBiocutarions.value = []

    if (newId && !oldId) {
      processQueue()
    } else if (newId) {
      BiocurationClassification.where({
        biological_collection_object_id: newId
      }).then(({ body }) => {
        biocurationList.value = body.map((item) => makeBiocurationObject(item))
      })
    }
  },
  { immediate: true }
)

watch(
  unsavedBiocurations,
  (newVal) => {
    if (props.biologicalId && newVal.length) {
      processQueue()
    }
  },
  { deep: true }
)

function addBiocuration(biocuration) {
  biocurationList.value.push(biocuration)
}

function processQueue() {
  const requests = biocurationList.value.map((id) =>
    BiocurationClassification.create(makeBiocurationPayload(id))
  )

  Promise.all(requests).then((responses) => {
    const created = biocurationList.value.filter((item) => item.id)
    biocurationList.value = [...created, ...responses.map((r) => r.body)]
  })
}

function isInList(id) {
  return !!biocurationList.value.find((bio) => id === bio.biocurationClassId)
}

function removeBiocuration(biocurationClass) {
  const index = biocurationList.value.findIndex(
    (item) => item.biocuration_class_id === biocurationClass.id
  )
  const biocuration = biocurationList.value[index]

  BiocurationClassification.destroy(biocuration.id).then(() => {
    biocurationList.value.splice(index, 1)
  })
}

function makeBiocurationObject(item) {
  return {
    id: item.id,
    uuid: crypto.randomUUID(),
    biocurationClassId: item.biocuration_class_id,
    biologicalId: props.biologicalId
  }
}

function makeBiocurationPayload(id) {
  return {
    biocuration_classification: {
      biocuration_class_id: id,
      biocuration_classification_object_id: props.biologicalId,
      biocuration_classification_object_type: FIELD_OCCURRENCE
    }
  }
}

async function splitGroups() {
  const { body: list } = await ControlledVocabularyTerm.where({
    type: ['BiocurationGroup', 'BiocurationClass']
  })

  const groups = list.filter(({ b }) => b.type === BIOCURATION_GROUP)
  const types = list.filter(({ b }) => b.type === BIOCURATION_CLASS)

  groups.forEach((group) => {
    Tag.where({ keyword_id: group.id }).then(({ body }) => {
      const tmpArray = []

      body.forEach((item) => {
        types.forEach((itemClass) => {
          if (itemClass.id === item.tag_object_id) {
            tmpArray.push(itemClass)
          }
        })
      })

      group.list = tmpArray
    })
  })

  return groups
}

splitGroups()
</script>

<style lang="scss" scoped>
.total-input {
  width: 50px;
}
.biocuration-toggle-button {
  min-width: 60px;
  border: 0px;
  margin-right: 6px;
  margin-bottom: 6px;
  border-top-left-radius: 14px;
  border-bottom-left-radius: 14px;

  &__disabled {
    opacity: 0.3;
  }
}
</style>

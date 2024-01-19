<template>
  <div>
    <div>
      <div
        v-for="group in biocurationsGroups"
        :key="group.id"
      >
        <label>{{ group.name }}</label>
        <br />
        <template
          v-for="item in group.list"
          :key="item.id"
        >
          <VBtn
            v-if="!isInList(item.id)"
            :color="objectId ? 'create' : 'primary'"
            medium
            class="biocuration-toggle-button"
            @click="addBiocuration(item)"
          >
            {{ item.name }}
          </VBtn>
          <VBtn
            v-else
            :color="objectId && 'destroy'"
            medium
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
import { BiocurationClassification } from '@/routes/endpoints'
import { FIELD_OCCURRENCE } from '@/constants'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  objectId: {
    type: [String, Number],
    default: undefined
  },

  biocurationsGroups: {
    type: Array,
    default: () => []
  }
})

const list = ref([])
const unsavedBiocurations = computed(() =>
  list.value.filter((item) => !item.id)
)

watch(
  () => props.objectId,
  (newId, oldId) => {
    if (newId && !oldId) {
      processUnsavedBiocurations()
    } else if (newId) {
      BiocurationClassification.where({
        biocuration_classification_object_id: newId,
        biocuration_classification_object_type: FIELD_OCCURRENCE
      }).then(({ body }) => {
        list.value = body.map((item) => makeBiocurationObject(item))
      })
    }
  },
  { immediate: true }
)

watch(
  unsavedBiocurations,
  (newVal) => {
    if (props.objectId && newVal.length) {
      processUnsavedBiocurations()
    }
  },
  { deep: true }
)

function addBiocuration(biocuration) {
  list.value.push(
    makeBiocurationObject({ biocuration_class_id: biocuration.id })
  )
}

function processUnsavedBiocurations() {
  const requests = unsavedBiocurations.value.map((item) =>
    BiocurationClassification.create(
      makeBiocurationPayload(item.biocurationClassId)
    )
  )

  Promise.all(requests).then((responses) => {
    const created = list.value.filter((item) => item.id)

    list.value = [
      ...created,
      ...responses.map((r) => makeBiocurationObject(r.body))
    ]
  })
}

function isInList(id) {
  return !!list.value.find((bio) => id === bio.biocurationClassId)
}

function removeBiocuration(biocurationClass) {
  const index = list.value.findIndex(
    ({ biocurationClassId }) => biocurationClassId === biocurationClass.id
  )
  const biocuration = list.value[index]

  if (biocuration.id) {
    BiocurationClassification.destroy(biocuration.id)
  }

  list.value.splice(index, 1)
}

function makeBiocurationObject(item) {
  return {
    id: item.id,
    uuid: crypto.randomUUID(),
    biocurationClassId: item.biocuration_class_id
  }
}

function makeBiocurationPayload(id) {
  return {
    biocuration_classification: {
      biocuration_class_id: id,
      biocuration_classification_object_id: props.objectId,
      biocuration_classification_object_type: FIELD_OCCURRENCE
    }
  }
}
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

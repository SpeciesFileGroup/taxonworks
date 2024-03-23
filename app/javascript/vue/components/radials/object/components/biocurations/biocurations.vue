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
          <button
            type="button"
            class="bottom button-submit normal-input biocuration-toggle-button"
            @click="createBiocuration(item.id)"
            v-if="!checkExist(item.id)"
          >
            {{ item.name }}
          </button>
          <button
            type="button"
            class="bottom button-delete normal-input biocuration-toggle-button"
            @click="
              () =>
                removeItem(
                  list.find((bio) => item.id === bio.biocuration_class_id)
                )
            "
            v-else
          >
            {{ item.name }}
          </button>
        </template>
      </div>
    </div>
  </div>
</template>

<script setup>
import {
  ControlledVocabularyTerm,
  BiocurationClassification,
  Tag
} from '@/routes/endpoints'
import { removeFromArray } from '@/helpers'
import { ref, onBeforeMount } from 'vue'
import { BIOCURATION_CLASS, BIOCURATION_GROUP } from '@/constants'

const props = defineProps({
  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: Number,
    required: true
  }
})

const emit = defineEmits(['update-count'])

const biocurationsType = ref([])
const biocurationsGroups = ref([])
const list = ref([])

onBeforeMount(async () => {
  const { body } = await ControlledVocabularyTerm.where({
    type: [BIOCURATION_GROUP, BIOCURATION_CLASS]
  })

  biocurationsType.value = body.filter(
    (item) => item.type === BIOCURATION_CLASS
  )
  biocurationsGroups.value = body.filter(
    (item) => item.type === BIOCURATION_GROUP
  )

  BiocurationClassification.where({
    biocuration_classification_object_id: props.objectId,
    biocuration_classification_object_type: props.objectType
  }).then(({ body }) => {
    list.value = body
  })

  splitGroups()
})

function createBiocuration(id) {
  const payload = {
    biocuration_classification: makeBiocurationObject(id)
  }

  BiocurationClassification.create(payload).then(({ body }) => {
    list.value.push(body)
    emit('update-count', list.value.length)
  })
}

function checkExist(id) {
  return list.value.some((bio) => id === bio.biocuration_class_id)
}

function makeBiocurationObject(id) {
  return {
    biocuration_class_id: id,
    biocuration_classification_object_id: props.objectId,
    biocuration_classification_object_type: props.objectType
  }
}
function removeItem(item) {
  BiocurationClassification.destroy(item.id).then(() => {
    removeFromArray(list.value, item)
    emit('update-count', list.value.length)
  })
}

function splitGroups() {
  biocurationsGroups.value.forEach((item) => {
    Tag.where({ keyword_id: item.id }).then(({ body }) => {
      const classes = []

      body.forEach((item) => {
        biocurationsType.value.forEach((itemClass) => {
          if (itemClass.id === item.tag_object_id) {
            classes.push(itemClass)
          }
        })
      })
      item.list = classes
    })
  })
}
</script>

<template>
  <div class="panel content">
    <h3>Annotations</h3>
    <div
      v-if="hasAnnotations || isLoading"
      class="flex-col gap-small"
    >
      <template
        v-for="(list, key) in annotations"
        :key="key"
      >
        <div v-if="list.length">
          <h4 class="capitalize">{{ ANNOTATIONS[key].title }}</h4>
          <ul>
            <li
              v-for="item in list"
              :key="item.id"
              v-html="item[ANNOTATIONS[key].label]"
            />
          </ul>
        </div>
      </template>
    </div>
    <p
      v-else
      class=""
    >
      No annotations found
    </p>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import {
  Citation,
  Tag,
  Note,
  Attribution,
  DataAttribute,
  Identifier,
  Confidence,
  Role
} from '@/routes/endpoints'

const props = defineProps({
  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  }
})

const ANNOTATIONS = {
  Citation: {
    label: 'object_tag',
    prefix: 'citation',
    service: Citation,
    title: 'citations'
  },
  Tag: {
    label: 'object_tag',
    prefix: 'tag',
    service: Tag,
    title: 'tags'
  },
  Note: {
    label: 'text',
    prefix: 'note',
    service: Note,
    title: 'notes'
  },
  Identifier: {
    label: 'object_tag',
    prefix: 'identifier',
    service: Identifier,
    title: 'Identifiers'
  },
  Confidence: {
    label: 'object_tag',
    prefix: 'confidence',
    service: Confidence,
    title: 'Confidences'
  },
  Verifier: {
    label: 'object_tag',
    prefix: 'role',
    service: Role,
    title: 'Verifiers'
  },
  DataAttribute: {
    label: 'object_tag',
    idParam: 'attribute_subject_id',
    typeParam: 'attribute_subject_type',
    service: DataAttribute,
    title: 'Data attributes'
  },
  Attribution: {
    label: 'object_tag',
    prefix: 'attribution',
    service: Attribution,
    title: 'Attribution'
  }
}

const annotations = ref({})
const isLoading = ref(false)
const hasAnnotations = computed(() =>
  Object.values(annotations.value).some((list) => list.length)
)

function loadAnnotations() {
  isLoading.value = true

  const requests = Object.entries(ANNOTATIONS).map(
    ([key, { prefix, service, typeParam, idParam }]) =>
      service
        .where({
          [idParam || `${prefix}_object_id`]: props.objectId,
          [typeParam || `${prefix}_object_type`]: props.objectType
        })
        .then(({ body }) => {
          annotations.value[key] = body
        })
        .catch(() => {})
  )

  Promise.all(requests).then(() => {
    isLoading.value = false
  })
}

watch(
  () => props.objectId,
  (newVal) => {
    if (newVal) {
      loadAnnotations(newVal)
    }
  },
  { immediate: true }
)
</script>

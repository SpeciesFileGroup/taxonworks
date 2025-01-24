<template>
  <div class="panel content">
    <h3>Annotations</h3>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import {
  Citation,
  Tag,
  Note,
  Attribution,
  DataAttribute,
  Identifier,
  Confidence,
  Verifier
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

const ANNOTATIONS = [
  {
    prefix: 'citation',
    title: 'citations',
    label: 'object_tag',
    service: Citation
  },
  {
    prefix: 'tag',
    title: 'Tags',
    label: 'object_tag',
    service: Tag
  },
  {
    prefix: 'note',
    title: 'Notes',
    label: 'text',
    service: Note
  },
  {
    prefix: 'identifier',
    title: 'identifiers',
    label: 'object_tag',
    service: Identifier
  },
  {
    prefix: 'confidence',
    title: 'Confidences',
    label: 'object_tag',
    service: Confidence
  },
  {
    prefix: 'verifier',
    title: 'Verifiers',
    label: 'object_tag',
    service: Verifier
  },
  {
    prefix: 'data_attribute',
    title: 'Data attributes',
    label: 'object_tag',
    service: DataAttribute
  },
  {
    prefix: 'attribution',
    title: 'Attribution',
    label: 'object_tag',
    service: Attribution
  }
]

const annotations = ref({})

function loadAnnotations() {
  ANNOTATIONS.forEach(({ prefix, service }) => {
    service
      .where({
        [`${prefix}_object_id`]: props.objectId,
        [`${prefix}_object_type`]: props.objectType
      })
      .then(({ body }) => {
        annotations[prefix] = body
      })
      .catch(() => {})
  })
}

watch(
  () => props.objectId,
  (newVal) => {
    if (newVal) {
      loadAnnotations
    }
  }
)
</script>

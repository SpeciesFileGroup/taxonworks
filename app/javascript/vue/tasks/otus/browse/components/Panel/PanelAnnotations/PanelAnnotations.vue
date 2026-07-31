<template>
  <PanelLayout
    :status="status"
    :title="title"
    :spinner="isLoading"
  >
    <div v-if="hasAnyAnnotation">
      <template
        v-for="(item, key) in annotations"
        :key="key"
      >
        <div
          v-if="hasAnnotations(item)"
          class="annotation-otu"
        >
          <h4
            class="annotation-otu-title"
            v-html="otus.find((otu) => otu.id == key)?.object_tag"
          />
          <div class="annotation-groups">
            <PanelAnnotationsList
              v-if="item.dataAttributes.length"
              title="Data attributes"
              :list="item.dataAttributes"
            />
            <PanelAnnotationsList
              v-if="item.identifiers.length"
              title="Identifiers"
              :list="item.identifiers"
            />
            <PanelAnnotationsList
              v-if="item.notes.length"
              title="Notes"
              :list="item.notes"
            />
            <PanelAnnotationsList
              v-if="item.tags.length"
              title="Tags"
              :list="item.tags"
            />
          </div>
        </div>
      </template>
    </div>
    <div v-else>No annotations available</div>
  </PanelLayout>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { Tag, Identifier, Note, DataAttribute } from '@/routes/endpoints'
import { OTU } from '@/constants'
import PanelLayout from '../PanelLayout.vue'
import PanelAnnotationsList from './PanelAnnotationsList.vue'

const props = defineProps({
  otu: {
    type: Object,
    required: true
  },

  otus: {
    type: Array,
    required: true
  },

  status: {
    type: String,
    default: 'unknown'
  },

  title: {
    type: String,
    default: 'Annotations'
  }
})

const annotations = ref({})
const isLoading = ref(false)

const hasAnyAnnotation = computed(() =>
  Object.values(annotations.value).some(hasAnnotations)
)

async function loadAnnotationsForOtu(otuId) {
  const [identifiers, tags, notes, dataAttributes] = await Promise.all([
    Identifier.where({
      identifier_object_id: otuId,
      identifier_object_type: OTU
    }),
    Tag.where({ tag_object_id: otuId, tag_object_type: OTU }),
    Note.where({ note_object_id: otuId, note_object_type: OTU }),
    DataAttribute.where({
      attribute_subject_id: otuId,
      attribute_subject_type: OTU
    })
  ])

  return {
    identifiers: identifiers.body,
    tags: tags.body,
    notes: notes.body,
    dataAttributes: dataAttributes.body
  }
}

async function loadAnnotations(otus) {
  isLoading.value = true

  try {
    const result = {}

    for (const otu of otus) {
      result[otu.id] = await loadAnnotationsForOtu(otu.id)
    }

    annotations.value = result
  } catch {
  } finally {
    isLoading.value = false
  }
}

function hasAnnotations(item) {
  return Object.values(item).some((list) => list.length)
}

watch(
  () => props.otus,
  (newVal) => {
    if (newVal.length > 0) {
      loadAnnotations(newVal)
    }
  },
  { immediate: true }
)
</script>

<style lang="scss" scoped>
.annotation-otu + .annotation-otu {
  margin-top: var(--spacing-lg);
  padding-top: var(--spacing-lg);
  border-top: 1px solid var(--border-color);
}

.annotation-otu-title {
  margin: 0 0 var(--spacing-sm);
  font-size: var(--font-size-base);
  font-weight: 600;
}

.annotation-groups {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-md);
  padding-left: var(--spacing-sm);
}
</style>

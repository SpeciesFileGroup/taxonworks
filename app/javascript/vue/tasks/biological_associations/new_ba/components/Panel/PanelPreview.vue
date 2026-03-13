<template>
  <BlockLayout :warning="!isTripleComplete">
    <template #header>
      <h3>Preview</h3>
    </template>
    <template #body>
      <div class="panel-preview">
        <template v-if="subjectAnatomicalPartLabel">
          <i v-html="subjectAnatomicalPartLabel" />

          <span class="sublet">of</span>
        </template>

        <span
          v-if="store.subject"
          v-html="subjectLabel"
        />
        <span v-else> [Subject] </span>

        <span
          v-if="store.relationship"
          v-html="store.relationship.object_tag"
        />
        <span v-else> [Relationship] </span>

        <template v-if="objectAnatomicalPartLabel">
          <i v-html="objectAnatomicalPartLabel" />

          <span class="sublet">of</span>
        </template>

        <span
          v-if="store.object"
          v-html="objectLabel"
        />
        <span v-else> [Related] </span>

        <template v-if="store.shape?.name">
          <span class="subtle">in</span>
          <span v-html="store.shape.name" />
        </template>

        <template v-if="citationLabel">
          <span class="subtle">, according to</span>
          <span v-html="store.shortCitation" />
        </template>
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from '../../store/store'
import BlockLayout from '@/components/layout/BlockLayout.vue'

const store = useStore()

const isTripleComplete = computed(
  () => !!(store.subject && store.relationship && store.object)
)

const subjectLabel = computed(() => store.subject?.object_tag)

const objectLabel = computed(() => store.object?.object_tag)

const subjectAnatomicalPartLabel = computed(() => {
  const ap = store.subjectAnatomicalPart
  if (!ap) return null
  return ap.uri_label || ap.name || null
})

const objectAnatomicalPartLabel = computed(() => {
  const ap = store.objectAnatomicalPart
  if (!ap) return null
  return ap.uri_label || ap.name || null
})

const citationLabel = computed(() => {
  if (!store.citation.source_id) return null

  let label = store.citation.label || ''

  if (store.citation.pages) {
    label += `: ${store.citation.pages}`
  }

  return label
})
</script>

<style scoped>
.panel-preview {
  display: flex;
  flex-wrap: wrap;
  align-items: baseline;
  gap: 0.25em;
  line-height: 1.6;
}
</style>

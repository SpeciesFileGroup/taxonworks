<template>
  <PanelLayout
    :status="status"
    :title="title"
    :spinner="isLoading"
  >
    <ul
      v-if="contents.length"
      class="content-list"
    >
      <li
        v-for="content in contents"
        :key="content.id"
      >
        <h4
          class="content-topic"
          v-html="content.topic.name"
        />
        <div
          class="content-body"
          v-html="markdownToHtml(content.text)"
        />
      </li>
    </ul>
    <div v-else>No content available</div>
  </PanelLayout>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Content } from '@/routes/endpoints'
import PanelLayout from '../PanelLayout.vue'
import DOMPurify from 'dompurify'
import { marked } from 'marked'

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
    default: 'Content'
  }
})

const contents = ref([])
const isLoading = ref(false)

function markdownToHtml(text) {
  return DOMPurify.sanitize(marked.parse(text ?? ''))
}

async function loadContents(otuId) {
  isLoading.value = true

  try {
    const { body } = await Content.filter({
      otu_id: otuId,
      most_recent_updates: 100,
      extend: ['topic']
    })

    contents.value = body
  } catch {
  } finally {
    isLoading.value = false
  }
}

watch(
  () => props.otu,
  (newVal) => {
    if (newVal?.id) {
      loadContents(newVal.id)
    }
  },
  { immediate: true }
)
</script>

<style lang="scss" scoped>
.content-list {
  margin: 0;
  padding: 0;
  list-style: none;

  li + li {
    margin-top: var(--spacing-md);
    padding-top: var(--spacing-md);
    border-top: 1px solid var(--border-color);
  }
}

.content-topic {
  margin: 0 0 var(--spacing-xxs);
  font-size: var(--font-size-sm);
  font-weight: 600;
}

.content-body {
  :deep(p),
  :deep(ul),
  :deep(ol),
  :deep(blockquote),
  :deep(pre) {
    margin: 0 0 var(--spacing-xs);
  }

  :deep(ul),
  :deep(ol) {
    padding-left: var(--spacing-lg);
  }

  :deep(h1),
  :deep(h2),
  :deep(h3),
  :deep(h4),
  :deep(h5),
  :deep(h6) {
    margin: var(--spacing-sm) 0 var(--spacing-xxs);
  }

  :deep(> *:first-child) {
    margin-top: 0;
  }

  :deep(> *:last-child) {
    margin-bottom: 0;
  }
}
</style>

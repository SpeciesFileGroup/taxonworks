<template>
  <PanelLayout
    :status="status"
    :title="title"
    :spinner="isLoading"
  >
    <div
      v-if="contents.length"
      class="separate-top"
    >
      <ul>
        <li
          v-for="content in contents"
          :key="content.id"
        >
          <b><span v-html="content.topic.name" /></b>
          <p
            class="pre"
            v-html="markdownToHtml(content.text)"
          />
        </li>
      </ul>
    </div>
    <div v-else>No content available</div>
  </PanelLayout>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Content } from '@/routes/endpoints'
import PanelLayout from '../PanelLayout.vue'
import EasyMDE from 'easymde/dist/easymde.min.js'
import DOMPurify from 'dompurify'

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
  const markdown = new EasyMDE()
  return DOMPurify.sanitize(markdown.options.previewRender(text))
}

async function loadContents(otuId) {
  isLoading.value = true

  try {
    const { body } = await Content.where({
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
li {
  border-bottom: 1px solid var(--border-color);
  margin-bottom: 12px;
}
li:last-child {
  border-bottom: none;
}
.pre {
  white-space: pre-wrap;
}
</style>

<template>
  <PanelLayout
    :status="status"
    :title="title"
    :spinner="isLoading"
    :empty="!contents.length"
  >
    <template v-if="contents.length">
      <section
        v-for="group in contentGroups"
        :key="group.otuId"
        class="content-group"
      >
        <h4
          v-if="isGroupHeaderVisible"
          class="content-otu"
        >
          <template v-if="group.otuId === otu.id">
            <span v-html="group.otu?.object_tag" />
            <span class="subtle font-light margin-xsmall-left">Current</span>
          </template>
          <a
            v-else
            :href="`${RouteNames.BrowseOtu}?otu_id=${group.otuId}`"
            data-turbolinks="false"
            v-html="group.otu?.object_tag || `OTU ${group.otuId}`"
          />
        </h4>
        <ul
          class="content-list"
          :class="{ 'content-list-grouped': isGroupHeaderVisible }"
        >
          <li
            v-for="content in group.contents"
            :key="content.id"
          >
            <h5
              class="content-topic"
              v-html="content.topic.name"
            />
            <div
              class="content-body"
              v-html="markdownToHtml(content.text)"
            />
          </li>
        </ul>
      </section>
    </template>
    <div v-else>No content available</div>
  </PanelLayout>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { Content } from '@/routes/endpoints'
import { RouteNames } from '@/routes/routes'
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

const PER_PAGE = 500

const contents = ref([])
const isLoading = ref(false)

const contentGroups = computed(() => {
  const otuOrder = [
    props.otu.id,
    ...props.otus.map((o) => o.id).filter((id) => id !== props.otu.id)
  ]
  const groups = new Map()

  contents.value.forEach((content) => {
    if (!groups.has(content.otu_id)) {
      groups.set(content.otu_id, {
        otuId: content.otu_id,
        otu: props.otus.find((o) => o.id === content.otu_id),
        contents: []
      })
    }

    groups.get(content.otu_id).contents.push(content)
  })

  return [...groups.values()].sort(
    (a, b) => otuOrder.indexOf(a.otuId) - otuOrder.indexOf(b.otuId)
  )
})

const isGroupHeaderVisible = computed(() =>
  contents.value.some((content) => content.otu_id !== props.otu.id)
)

function markdownToHtml(text) {
  return DOMPurify.sanitize(marked.parse(text ?? ''))
}

async function loadContents(otuIds) {
  isLoading.value = true

  try {
    const { body } = await Content.filter({
      otu_id: otuIds,
      per: PER_PAGE,
      extend: ['topic']
    })

    contents.value = body
  } catch {
  } finally {
    isLoading.value = false
  }
}

watch(
  () => props.otus,
  (newVal) => {
    const otuIds = newVal.map((o) => o.id)

    if (otuIds.length) {
      loadContents(otuIds)
    }
  },
  { immediate: true }
)
</script>

<style lang="scss" scoped>
.content-group + .content-group {
  margin-top: var(--spacing-lg);
}

.content-otu {
  margin: 0 0 var(--spacing-sm);
  padding: var(--spacing-xs) var(--spacing-sm);
  background-color: var(--bg-muted);
  border-radius: var(--border-radius-small);
  font-size: var(--font-size-sm);
  font-weight: 600;
}

.content-list {
  margin: 0;
  padding: 0;
  list-style: none;

  &.content-list-grouped {
    margin-left: var(--spacing-sm);
    padding-left: var(--spacing-md);
    border-left: 2px solid var(--border-color);
  }

  li + li {
    margin-top: var(--spacing-md);
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

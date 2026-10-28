<template>
  <nav class="pagination">
    <span
      v-tooltip="'Previous page'"
      class="prev"
    >
      <a
        :class="isFirstPage ? 'disabled' : 'cursor-pointer'"
        :aria-disabled="isFirstPage"
        @click="!isFirstPage && sendPage(currentPage - 1)"
      >
        ‹
      </a>
    </span>

    <template
      v-for="(item, index) in pageItems"
      :key="index"
    >
      <span
        v-if="item === GAP"
        class="page gap"
      >
        …
      </span>
      <span
        v-else
        :class="['page', { current: item === currentPage }]"
      >
        <a
          v-if="item !== currentPage"
          class="cursor-pointer"
          @click="sendPage(item)"
        >
          {{ item }}
        </a>
        <template v-else>{{ item }}</template>
      </span>
    </template>

    <span
      v-tooltip="'Next page'"
      class="next"
    >
      <a
        :class="isLastPage ? 'disabled' : 'cursor-pointer'"
        :aria-disabled="isLastPage"
        @click="!isLastPage && sendPage(currentPage + 1)"
      >
        ›
      </a>
    </span>
  </nav>
</template>

<script setup>
import { computed } from 'vue'
import { vTooltip } from '@/directives'

const props = defineProps({
  pagination: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['nextPage'])

const GAP = 'gap'
const RANGE_PAGES = 2
const MAX_ITEMS = 2 * RANGE_PAGES + 5

const currentPage = computed(() => props.pagination.paginationPage || 1)

const totalPages = computed(() => props.pagination.totalPages || 1)

const isFirstPage = computed(() => currentPage.value <= 1)

const isLastPage = computed(() => currentPage.value >= totalPages.value)

const pageItems = computed(() => {
  const current = currentPage.value
  const total = totalPages.value
  const edgeLength = MAX_ITEMS - 2

  if (total <= MAX_ITEMS) {
    return range(1, total)
  }

  if (current <= edgeLength - RANGE_PAGES) {
    return [...range(1, edgeLength), GAP, total]
  }

  if (current > total - edgeLength + RANGE_PAGES) {
    return [1, GAP, ...range(total - edgeLength + 1, total)]
  }

  return [
    1,
    GAP,
    ...range(current - RANGE_PAGES, current + RANGE_PAGES),
    GAP,
    total
  ]
})

function range(start, end) {
  return Array.from({ length: end - start + 1 }, (_, i) => start + i)
}

function sendPage(page) {
  emit('nextPage', { page })
}
</script>

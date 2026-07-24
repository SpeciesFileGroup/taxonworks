<template>
  <nav class="pagination">
    <span
      v-if="showFirst"
      v-tooltip="'First page'"
      class="first cursor-pointer"
      @click="sendPage(1)"
    >
      <a>«</a>
    </span>
    <span
      v-if="showPrevious"
      v-tooltip="'Previous page'"
      class="prev cursor-pointer"
      @click="sendPage(pagination.previousPage)"
    >
      <a>‹</a>
    </span>

    <span
      v-if="pagination.paginationPage > rangePages"
      class="page gap"
    >
      ...
    </span>

    <span
      v-for="n in visiblePages"
      :key="n"
      :class="['page', { current: n == pagination.paginationPage }]"
    >
      <a
        v-if="n != pagination.paginationPage"
        class="cursor-pointer"
        @click="sendPage(n)"
      >
        {{ n }}
      </a>
      <template v-else>{{ n }}</template>
    </span>

    <span
      v-if="pagination.totalPages - pagination.paginationPage >= rangePages"
      class="page gap"
    >
      ...
    </span>

    <span
      v-if="showNext"
      v-tooltip="'Next page'"
      class="next cursor-pointer"
      @click="sendPage(pagination.nextPage)"
    >
      <a>›</a>
    </span>
    <span
      v-if="showLast"
      v-tooltip="'Last page'"
      class="last cursor-pointer"
      @click="sendPage(pagination.totalPages)"
    >
      <a>»</a>
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

const rangePages = 5

const pagesCount = computed(() =>
  Object.keys(props.pagination).length ? props.pagination.totalPages : 1
)

const rangeMax = computed(() => props.pagination.paginationPage + rangePages)

const rangeMin = computed(() => props.pagination.paginationPage - rangePages)

const visiblePages = computed(() => {
  const pages = []

  for (let n = 1; n <= pagesCount.value; n++) {
    if (n < rangeMax.value && rangeMin.value < n) pages.push(n)
  }

  return pages
})

const showFirst = computed(
  () => props.pagination.paginationPage != 1 && props.pagination.paginationPage
)

const showPrevious = computed(
  () =>
    props.pagination?.previousPage &&
    props.pagination.paginationPage !== props.pagination.previousPage
)

const showNext = computed(
  () => props.pagination?.nextPage !== props.pagination.totalPages
)

const showLast = computed(
  () =>
    props.pagination.paginationPage != props.pagination.totalPages &&
    props.pagination.totalPages > 1
)

function sendPage(page) {
  emit('nextPage', { page })
}
</script>

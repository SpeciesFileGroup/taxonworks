<template>
  <nav class="pagination">
    <span
      v-if="showFirst"
      class="first cursor-pointer"
      @click="sendPage(1)"
    >
      <a>«</a>
    </span>
    <span
      v-if="showPrevious"
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
      class="next cursor-pointer"
      @click="sendPage(pagination.nextPage)"
    >
      <a>›</a>
    </span>
    <span
      v-if="showLast"
      class="last cursor-pointer"
      @click="sendPage(pagination.totalPages)"
    >
      <a>»</a>
    </span>
  </nav>
</template>

<script>
export default {
  props: {
    pagination: {
      type: Object,
      required: true
    }
  },

  emits: ['nextPage'],

  computed: {
    pagesCount() {
      return Object.keys(this.pagination).length
        ? this.pagination.totalPages
        : 1
    },

    rangeMax() {
      return this.pagination.paginationPage + this.rangePages
    },

    rangeMin() {
      return this.pagination.paginationPage - this.rangePages
    },

    visiblePages() {
      const pages = []

      for (let n = 1; n <= this.pagesCount; n++) {
        if (n < this.rangeMax && this.rangeMin < n) pages.push(n)
      }

      return pages
    },

    showFirst() {
      return this.pagination.paginationPage != 1 && this.pagination.paginationPage
    },

    showPrevious() {
      return (
        this.pagination?.previousPage &&
        this.pagination.paginationPage !== this.pagination.previousPage
      )
    },

    showNext() {
      return this.pagination?.nextPage !== this.pagination.totalPages
    },

    showLast() {
      return (
        this.pagination.paginationPage != this.pagination.totalPages &&
        this.pagination.totalPages > 1
      )
    }
  },

  data() {
    return {
      rangePages: 5
    }
  },

  methods: {
    sendPage(page) {
      this.$emit('nextPage', { page })
    }
  }
}
</script>

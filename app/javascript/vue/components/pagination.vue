<template>
  <div class="horizontal-left-content ">
    <div class="page-navigator separate-right">
      <template>
        <span v-if="pagination['previousPage'] && pagination['previousPage'] != 1">
          <a
            class="cursor-pointer"
            @click="sendPage(pagination.previousPage)">
            ‹ Back
          </a>
        </span>
        <span
          v-else
          class="disabled">
          ‹ Back
        </span>
      </template>
      <template>
        <span v-if="pagination['nextPage'] && pagination['nextPage'] != pagination.totalPages">
          <a
            class="cursor-pointer"
            @click="sendPage(pagination.nextPage)">Next ›
          </a>
        </span>
        <span
          v-else
          class="disabled">
          Next ›
        </span>
      </template>
    </div>
    <nav>
      <span
        v-if="pagination.paginationPage > rangePages"
        class="page gap">...</span>
      <span
        :class="{ current: n == pagination.paginationPage}"
        v-for="n in pagesCount">
        <template v-if="n < rangeMax && rangeMin < n">
          <span v-if="n == pagination.paginationPage">{{ n }}</span>
          <a
            v-else
            class="cursor-pointer page"
            @click="sendPage(n)">
            {{ n }}
          </a>
        </template>
      </span>
      <span
        v-if="(pagination.totalPages - pagination.paginationPage) >= rangePages"
        class="page gap">...</span>
      <span
        v-if="pagination.paginationPage != 1 && pagination.paginationPage"
        @click="sendPage(1)"
        class="first cursor-pointer">
        <a>« First</a>
      </span>
      <span
        v-if="pagination.paginationPage != pagination.totalPages"
        @click="sendPage(pagination.totalPages)"
        class="last cursor-pointer">
        <a>Last »</a>
      </span>
    </nav>
  </div>
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
      if(Object.keys(this.pagination).length)
        return this.pagination.totalPages
      return 1
    },

    rangeMax () {
      return this.pagination.paginationPage + this.rangePages
    },

    rangeMin () {
      return this.pagination.paginationPage - this.rangePages
    }
  },
  data () {
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

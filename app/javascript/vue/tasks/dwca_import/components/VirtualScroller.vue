<template>
  <table
    style="white-space: nowrap;">
    <thead>
      <tr>
        <slot name="header"/>
      </tr>
    </thead>
    <tbody
      v-for="pageNumber in pagination.totalPages"
      ref="pages"
      :key="pageNumber">
      <template v-if="pages[pageNumber] && visiblePages.includes(pageNumber)">
        <template v-for="(row, rIndex) in pages[pageNumber].rows">
          <slot :item="{ row: row, index: rIndex}"/>
        </template>
      </template>
      <template v-else>
        <tr
          class="empty-body"
          :style="{ height: itemHeight * pagination.perPage + 'px'}">
          <td
            colspan="100"
            class="full_width"></td>
        </tr>
      </template>
    </tbody>
    <slot name="footer"/>
  </table>
</template>

<script>

export default {
  props: {
    pages: {
      type: Array,
      required: true
    },
    itemHeight: {
      type: Number,
      default: 40
    },
    pagination: {
      type: Object,
      default: undefined
    }
  },
  data () {
    return {
      visiblePages: [0],
      timeout: undefined
    }
  },
  watch: {
    pages (newVal) {
      this.handleScroll()
    }
  },
  mounted () {
    window.addEventListener('scroll', this.handleScroll)
  },
  methods: {
    handleScroll () {
      clearTimeout(this.timeout)
      this.timeout = setTimeout(() => {
        const currentPages = []
        this.$refs.pages.forEach(function (page, i) {
          const rect = page.getBoundingClientRect()
          if (rect.top - window.innerHeight < 0 && rect.bottom >= 0) {
            currentPages.push(i + 1)
          }
        })
        if (currentPages.every(item => this.visiblePages.includes(item))) return
        this.visiblePages = currentPages
        this.$emit('currentPages', currentPages)
      }, 200)
    }
  },
  destroyed () {
    window.removeEventListener('scroll', this.handleScroll)
  }
}
</script>
<style lang="scss">
  .empty-body {
    background: linear-gradient(transparent,transparent 20%,hsla(0,0%,50.2%,0.03) 0,hsla(0,0%,50.2%,0.08) 50%,hsla(0,0%,50.2%,0.03) 80%,transparent 0,transparent);
    background-size:100% 40px
  }
</style>

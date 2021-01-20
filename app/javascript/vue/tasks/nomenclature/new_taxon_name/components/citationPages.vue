<template>
  <input
    type="text"
    :disabled="!isCitationExist"
    class="pages"
    @input="updatePages(false)"
    @blur="updatePages(true)"
    :value="pages"
    placeholder="Pages">
</template>

<script>
export default {
  props: ['citation'],
  computed: {
    pages () {
      return this.citation?.origin_citation ? this.citation.origin_citation.pages : ''
    },
    isCitationExist () {
      return this.citation?.origin_citation
    }
  },
  methods: {
    updatePages (immediate) {
      if (!this.citation?.origin_citation) return
      const eventName = immediate ? 'save' : 'setPages'
      const item = this.citation
      const newCitation = {
        id: (item?.origin_citation ? item.origin_citation.id : null),
        source_id: (item?.origin_citation ? item.origin_citation.source.id : null),
        pages: this.$el.value
      }
      if (this.isCitationExist) {
        this.$emit(eventName, newCitation)
      }
    }
  }
}
</script>

<style scoped>
.pages {
  margin-left: 8px;
  width: 70px;
}
.pages:disabled {
  background-color: #F5F5F5;
}
</style>

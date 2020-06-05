<template>
  <input
    type="text"
    :disabled="!getCitation(citation)"
    class="pages"
    @input="autoSave(citation)"
    :value="getPages(citation)"
    placeholder="Pages">
</template>

<script>
export default {
  props: ['citation'],
  data: function () {
    return {
      autosave: undefined
    }
  },
  methods: {
    autoSave (item) {
      this.setPages(this.$el.value, item)
    },
    getPages (item) {
      return (item.hasOwnProperty('origin_citation') ? item.origin_citation.pages : '')
    },
    setPages (value, item) {
      if (item['origin_citation'] == undefined) return

      let citation = {
        id: item.id,
        origin_citation_attributes: {
          id: (item.hasOwnProperty('origin_citation') ? item.origin_citation.id : null),
          source_id: (item.hasOwnProperty('origin_citation') ? item.origin_citation.source.id : null),
          pages: value
        }
      }
      if (this.getCitation(this.citation)) {
        this.$emit('setPages', citation)
      }
    },
    getCitation: function (item) {
      return (item.hasOwnProperty('origin_citation') ? item.origin_citation.source.object_tag : undefined)
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

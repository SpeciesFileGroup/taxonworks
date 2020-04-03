<template>
  <div>
    <div class="field">
      <label>Start year</label>
      <input
        type="text"
        v-model="source.year_start">
    </div>
    <div class="field">
      <label>End year</label>
      <input
        type="text"
        v-model="source.year_end">
    </div>
  </div>
</template>

<script>

export default {
  props: {
    value: {
      type: Object,
      default: undefined
    }
  },
  computed: {
    source: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      authors: []
    }
  },
  watch: {
    authors: {
      handler (newVal) {
        this.source.author_ids = this.authors.map(author => { return author.id })
      },
      deep: true
    }
  },
  methods: {
    addAuthor (author) {
      this.authors.push(author)
    }
  }
}
</script>

<template>
  <input
    v-model="topic.pages"
    @input="updatePage"
    type="text">
</template>

<script>
export default {
  props: {
    value: {
      type: Object,
      required: true
    },
    citationId: {
      type: [String, Number],
      required: true
    }
  },
  computed: {
    topic: {
      get () {
        return this.value
      },
      set(value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      delay: 1000,
      timer: undefined
    }
  },
  methods: {
    updatePage() {
      let that = this
      clearTimeout(this.timer)
      this.timer = setTimeout(() => {
        that.$emit('update', {
          id: this.citationId,
          citation_topics_attributes: [{
            id: this.topic.id,
            pages: this.topic.pages
          }]
        })
      }, this.delay)
    }
  }
}
</script>

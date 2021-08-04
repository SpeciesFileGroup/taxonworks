<template>
  <input
    v-model="topic.pages"
    @input="updatePage"
    type="text">
</template>

<script>
export default {
  props: {
    modelValue: {
      type: Object,
      required: true
    },
    citationId: {
      type: [String, Number],
      required: true
    }
  },

  emits: [
    'update:modelValue',
    'update'
  ],

  computed: {
    topic: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
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
    updatePage () {
      clearTimeout(this.timer)
      this.timer = setTimeout(() => {
        this.$emit('update', {
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

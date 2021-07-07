<template>
  <button
    :style="{ borderRightColor: topic.css_color, borderRightWidth: '4px', borderRightStyle: 'solid' }"
    @click="sendTopic(topic.id)"
    type="button"
    class="normal-input button tag_button">
    {{ topic.name }}
  </button>
</template>

<script>
export default {
  props: {
    topic: {
      type: Object,
      required: true
    }
  },

  emits: ['select'],

  methods: {
    sendTopic () {
      this.$emit('select', this.topic)
    }
  }
}
</script>

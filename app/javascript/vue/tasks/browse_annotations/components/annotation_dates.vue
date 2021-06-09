<template>
  <div class="flex-wrap-column">
    <label>After:</label>
    <input
      v-model="annotation_dates.after"
      name="dateStart"
      type="date"
      @change="sendDate()">
    <label class="separate-top">Before:</label>
    <input
      v-model="annotation_dates.before"
      name="dateEnd"
      type="date"
      @change="sendDate()">
  </div>
</template>

<script>
export default {
  props: {
    value: {
      type: Object
    }
  },

  data () {
    return {
      annotation_dates: {
        after: undefined,
        before: undefined
      }
    }
  },

  watch: {
    value(newVal) {
      this.annotation_dates = newVal
    }
  },

  methods: {
    sendDate() {
      if(this.annotation_dates.after == "") this.annotation_dates.after = undefined
      if(this.annotation_dates.before == "") this.annotation_dates.before = undefined
      this.$emit('input', this.annotation_dates)
    }
  }
}
</script>
<style scoped>
  input {
    width: 150px;
  }
</style>

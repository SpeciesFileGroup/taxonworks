<template>
  <div class="flexbox middle">
    After:
    <input
      v-model="annotation_dates.after"
      name="dateStart"
      type="date"
      @change="getResult()">Before:
    <input
      v-model="annotation_dates.before"
      name="dateEnd"
      type="date"
      @change="getResult()">
  </div>
</template>

<script>
  export default {
    props: {
      value: {
        type: Object,
      }
    },
    data: function () {
      return {
        annotation_dates: {
          after: undefined,
          before: undefined
        },
      }
    },
    watch: {
      value(newVal) {
        this.annotation_dates = newVal
      }
    },
    methods: {
      getResult() {
          this.$emit('input', this.annotation_dates);
      }
    }
  }
</script>
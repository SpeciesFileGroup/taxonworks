<template>
  <div class="year-box">
    <ul class="no_bullets">
      <li
        class="full_width year-line"
        v-for="(value, year) in years"
        :key="year"
        :style="{
          background: `linear-gradient(to right, #5D9ECE ${getSize(value)}%, transparent ${getSize(value)}% ${100-getSize(value)}%)`
          }">
        <div
          class="full_width year-string"
          :style="{
            background: `linear-gradient(to right, white ${getSize(value)}%, black ${getSize(value)}% ${100-getSize(value)}%)`,
            '-webkit-background-clip': 'text',
            '-webkit-text-fill-color': 'transparent'
          }"
          >{{ year }}</div>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  props: {
    years: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      max: undefined
    }
  },
  watch: {
    years: {
      handler(newVal) {
        this.setYears(newVal)
      },
      immediate: true
    }
  },
  methods: {
    setYears (years) {
      this.max = Math.max(...Object.values(years))
    },
    getSize (value) {
      return (value / this.max) * 100
    }
  }
}
</script>

<style scoped>
  .year-box {
    overflow-y: scroll;
    overflow-x: hidden;
    max-height: 400px;
  }
  .year-line {
    margin: 4px;
    border-radius: 4px;
    padding-right: 4px;
    cursor: pointer;
  }
  .year-string {
    padding-left: 4px;
    padding-right: 0px;

  }
</style>
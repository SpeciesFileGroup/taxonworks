<template>
  <div class="year-box">
    <ul class="no_bullets">
      <li
        class="full_width year-line"
        v-for="(count, year) in years"
        @click="setYear(Number(year))"
        :key="year"
        :style="{
          background: `linear-gradient(to right, ${value === Number(year) ? '#F5F5F5' : '#5D9ECE'} ${getSize(count)}%, transparent ${getSize(count)}% ${100-getSize(count)}%)`
          }">
        <div
          class="full_width year-string"
          :style="{
            background: `linear-gradient(to right, white ${getSize(count)}%, black ${getSize(count)}% ${100-getSize(count)}%)`,
            '-webkit-background-clip': 'text',
            '-webkit-text-fill-color': value === Number(year) ? 'black' : 'transparent'
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
    },
    value: {
      type: [Number, String],
      default: undefined
    }
  },
  data () {
    return {
      max: undefined,
    }
  },
  watch: {
    years: {
      handler(newVal) {
        this.max = Math.max(...Object.values(newVal))
      },
      immediate: true
    }
  },
  methods: {
    setYear (year) {
      this.$emit('input', this.value === year ? undefined : year)
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
    max-height: 450px;
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
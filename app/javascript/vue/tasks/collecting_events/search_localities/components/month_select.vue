<template>
  <div>
    <select v-model="monthSelected">
      <option
        v-for="(month, index) in months"
        :key="month"
        :value="(index+1)"> {{ month }} </option>
    </select>
  </div>
</template>
<script>
  export default {
    data() {
      return {
        monthSelected: '',
        months: ['January', ' February', 'March', 'April', 'May', 'June', 'July', ' August', 'September', 'October', 'November', 'December']
      }
    },
    watch: {
      monthSelected() {
        this.$emit('month', this.monthSelected)
      }
    }
  }
</script>

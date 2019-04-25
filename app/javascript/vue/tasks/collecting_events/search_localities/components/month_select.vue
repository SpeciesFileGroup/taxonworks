<template>
  <div>
    <select v-model="monthSelected">
      <option
        v-for="(month, index) in months"
        :key="month"
        :value="(index == 0 ? '' : index)"> {{ month }} </option>
    </select>
  </div>
</template>
<script>
  export default {
    data() {
      return {
        monthSelected: '',
        months: ['', 'January', ' February', 'March', 'April', 'May', 'June', 'July', ' August', 'September', 'October', 'November', 'December']
      }
    },
    watch: {
      monthSelected() {
        this.$emit('month', this.monthSelected.toString())
      }
    }
  }
</script>

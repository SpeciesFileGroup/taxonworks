<template>
  <div>
    <select name="name" v-model="selected">
      <option value="" label=" "></option>
      <option value="1">January</option>
      <option value="2">February</option>
      <option value="3">March</option>
      <option value="4">April</option>
      <option value="5">May</option>
      <option value="6">June</option>
      <option value="7">July</option>
      <option value="8">August</option>
      <option value="9">September</option>
      <option value="10">October</option>
      <option value="11">November</option>
      <option value="12">December</option>
    </select>
    {{selected}}
  </div>
</template>
<script>
  export default {
    props: {
      name: {
        type: String,
        default: ''
      }
    },
    data() {
      return {
        selected: ''
      }
    }
  }
</script>
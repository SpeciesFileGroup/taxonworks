<template>
  <div>
    <h2>Precision</h2>
    <div class="options-label">
      <span
        v-for="option in options"
        v-html="option.label"/>
    </div>
    <datalist id="days">
      <option
        v-for="option in options"
        :value="option.value"
        :label="option.label"/>
    </datalist>
    <input type="range" list="days" max="4" min="0">
  </div>
</template>

<script>
export default {
  data() {
    return {
      options: [
        {
          value: 0,
          label: 'Any time'
        },
        {
          value: 1,
          label: '1'
        },
        {
          value: 2,
          label: '10'
        },
        {
          value: 3,
          label: '100'
        },
        {
          value: 4,
          label: '365'
        }
      ]
    }
  }
}
</script>

<style lang="scss" scoped>
.options-label {
  display: flex;
  width: 300px;
  justify-content: space-between;
  span {
    width: 60px;
  }
}
  datalist {
    display: flex;
    justify-content: space-between;
    margin-top: -23px;
    padding-top: 0px;
    width: 300px;
  }
  input[type="range"] {
    width: 300px;
  }
  option {
      width: 1px;
      height: 4px;
      border-left: 1px solid #000;
      z-index: -1;
  }
</style>

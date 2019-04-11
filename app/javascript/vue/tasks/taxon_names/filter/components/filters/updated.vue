<template>
  <div>
    <h2>Precision</h2>
    <datalist id="days">
      <option
        v-for="(option, index) in options"
        :value="index"/>
    </datalist>
    <input
      type="range"
      list="days"
      value="0"
      min="0"
      max="4"
      step="0"
      v-model="optionValue">
    <div class="options-label">
      <span
        v-for="option in options"
        v-html="option.label"/>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    value: {
      default: undefined
    }
  },
  computed: {
    optionValue: {
      get() {
        return this.value ? this.value : 0
      },
      set(value) {
        this.$emit('input', this.options[value].value)
      }
    }
  },
  data() {
    return {
      options: [
        {
          value: undefined,
          label: 'Any time'
        },
        {
          value: 1,
          label: '1'
        },
        {
          value: 10,
          label: '10'
        },
        {
          value: 100,
          label: '100'
        },
        {
          value: 365,
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
  width: 262px;
  padding: 0 21px;
  margin-top: -10px;
  justify-content: space-between;
  span {
    position: relative;
    display: flex;
    justify-content: center;
    text-align: center;
    width: 1px;
    white-space: nowrap;
    background: #D3D3D3;
    height: 10px;
    line-height: 40px;
    margin: 0 0 20px 0;
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

</style>

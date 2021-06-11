<template>
  <div>
    <h3>Updated</h3>
    <datalist id="days">
      <option
        v-for="(option, index) in options"
        :value="index"/>
    </datalist>
    <input
      type="range"
      list="days"
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

import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  props: {
    modelValue: {
      default: undefined
    }
  },

  emits: ['update:modelValue'],

  computed: {
    optionValue: {
      get () {
        return this.modelValue || 0
      },
      set(value) {
        this.$emit('update:modelValue', this.options[value].value)
      }
    }
  },

  data () {
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
  },
  mounted () {
    const params = URLParamsToJSON(location.href)
    if (params.updated_since) {
      const date = new Date(params.updated_since)
      const today = new Date()
      const diffInTyme = today.getTime() - date.getTime()
      const dffInDay = diffInTyme / (1000 * 3600 * 24)
      this.$emit('input', Math.floor(dffInDay))
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

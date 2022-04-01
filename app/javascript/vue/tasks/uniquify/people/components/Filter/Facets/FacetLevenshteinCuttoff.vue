<template>
  <div class="field">
    <h3>Levenshtein cuttoff</h3>
    <datalist id="days">
      <option
        v-for="n in 7"
        :key="n"
        :value="n-1"
      />
    </datalist>
    <input
      type="range"
      list="days"
      min="0"
      max="6"
      step="0"
      v-model.number="optionValue"
    >
    <div class="options-label">
      <span
        :key="n"
        v-for="n in 7"
        v-html="n-1"
      />
    </div>
  </div>
</template>

<script>
export default {
  props: {
    modelValue: {
      type: [Number, String],
      default: 0
    }
  },

  emits: ['update:modelValue'],

  computed: {
    optionValue: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value === 0 ? undefined : value)
      }
    }
  }
}
</script>
<style lang="scss" scoped>
.options-label {
  display: flex;
  width: 268px;
  padding: 0 19px;
  margin-top: -10px;
  justify-content: space-between;
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

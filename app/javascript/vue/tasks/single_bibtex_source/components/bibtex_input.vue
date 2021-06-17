<template>
  <div>
    <textarea
      rows=20
      cols=50
      v-model="bibtexInput"
      placeholder="@article{naumann1988ambositrinae,
    title={Ambositrinae (Insecta: Hymenoptera: Diapriidae)},
    author={Naumann, Ian D},
    journal={Fauna of New Zealand},
    volume={15},
    year={1988}
}"/>
  </div>
</template>
<script>
export default {
  props: {
    value: {
      type: String,
      default: ''
    }
  },

  emits: ['update:modelValue'],

  computed: {
    bibtexInput: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  }
}
</script>

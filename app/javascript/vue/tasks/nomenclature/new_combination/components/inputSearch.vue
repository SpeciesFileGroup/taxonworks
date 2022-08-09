<template>
  <div class="horizontal-left-content">
    <input
      class="big-input"
      @input="processString(type)"
      type="text"
      ref="search"
      :disabled="disabled"
      :placeholder="placeholder"
      v-model="type">
    <button
      tabindex="-1"
      class="big-input separate-left button button-default"
      @click="reset()"
    >New
    </button>
  </div>
</template>

<script>

export default {
  props: {
    timeBeforeSend: {
      type: Number,
      default: 1000
    },
    placeholder: {
      type: String,
      default: undefined
    }
  },

  emits: ['onTaxonName'],

  data () {
    return {
      type: '',
      disabled: false,
      timeOut: undefined
    }
  },

  mounted () {
    this.focusInput()
  },

  methods: {
    reset () {
      this.type = ''
      this.sendTaxonName()
      this.disabledButton(false)
    },

    focusInput () {
      this.$refs.search.focus()
    },

    disabledButton (status) {
      this.disabled = status
    },

    processString (str) {
      str = this.removeSpaces(str)
      this.capitalize(str)
      this.addTimer()
    },

    removeSpaces (str) {
      str = str.replace(/^\s+|\s{2,}$|\s\.\s/g, '')
      str = str.replace(/\s{2,}/g, ' ')
      return str
    },

    capitalize (str) {
      this.type = str.charAt(0).toUpperCase() + str.substring(1)
    },

    GenusAndSpecies () {
      return (this.type.split(' ').length > 1 && this.type.split(' ')[1].length > 2)
    },

    sendTaxonName () {
      this.$emit('onTaxonName', this.type)
    },

    addTimer () {
      clearTimeout(this.timeOut)
      this.timeOut = setTimeout(() => {
        this.sendTaxonName()
      }, this.timeBeforeSend)
    }
  }
}
</script>

<style scoped>
input {
  width: 100%;
  min-width: 400px;
}
button {
  width: 100px;
}
</style>

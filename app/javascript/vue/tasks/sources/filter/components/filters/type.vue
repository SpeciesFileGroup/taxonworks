<template>
  <div>
    <h2>Type</h2>
    <ul class="no_bullets context-menu">
      <li v-for="(item, key) in types">
        <label class="capitalize">
          <input
            v-model="type"
            :value="key"
            type="radio">
          {{ item }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  props: {
    value: {
      type: String,
      default: undefined
    }
  },
  computed: {
    type: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      types: {
        'Source::Bibtex': 'Bibtex',
        'Source::Verbatim': 'Verbatim',
        'Source::Human': 'Human'
      }
    }
  }
}
</script>

<style>

</style>
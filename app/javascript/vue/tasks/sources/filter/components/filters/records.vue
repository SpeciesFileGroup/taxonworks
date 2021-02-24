<template>
  <div>
    <h3>By records with</h3>
    <ul class="no_bullets">
      <li v-for="(item, key) in params">
        <label class="capitalize">
          <input
            :key="key"
            :value="item"
            type="checkbox"
            v-model="value[key]">
            {{ key }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  props: {
    value: {
      type: Object,
      required: true
    }
  },
  computed: {
    params: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  }
}
</script>

<style>

</style>
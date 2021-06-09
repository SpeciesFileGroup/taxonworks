<template>
  <div class="flexbox">
    <ul class="no_bullets">
      <li v-for="option in options">
        <label @click="selectLogic(option)">
          <input
            :checked="modelValue === option"
            name="annotation-logic"
            type="radio"
            :value="option">
          <span
            class="capitalize"
            v-html="option"/>
        </label>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  props: {
    modelValue: {
      type: String
    }
  },

  emits: ['update:modelValue'],

  data () {
    return {
      options: ['replace', 'append']
    }
  },

  methods: {
    selectLogic (type) {
      this.$emit('update:modelValue', type)
    }
  }
}
</script>

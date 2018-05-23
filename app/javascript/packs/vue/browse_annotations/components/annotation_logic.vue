<template>
  <div class="flexbox">
    <ul class="no_bullets">
      <li v-for="option in options">
        <label @click="selectLogic(option)">
          <input
            :checked="value === option"
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
      value: {
        type: String,
      }
    },
    watch: {
      value(newVal) {
        this.getResult(newVal)
      }
    },
    data: function () {
      return {
        options: ['replace', 'append']
      }
    },
    methods: {
      selectLogic(type) {
        this.$emit('input', type)
      }
    }
  }
</script>
<template>
  <div style="max-height: 450px;">
    <ul class="no_bullets">
      <li
        v-for="item in list"
        :key="item.id">
        <label class="middle">
          <input
            :type="type"
            :value="item.id"
            v-model="selected"
            class="button normal-input button-default">
          <span v-html="item.object_tag"/>
        </label>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  props: {
    modelValue: {
      type: [Array, Number],
      default: () => []
    },

    list: {
      type: Array,
      required: true
    },

    type: {
      type: String,
      default: 'checkbox'
    }
  },

  emits: ['update:modelValue'],

  computed: {
    selected: {
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

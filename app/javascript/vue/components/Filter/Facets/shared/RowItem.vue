<template>
  <tr>
    <td>
      <span v-html="item[label]"/>
    </td>
    <td>
      <div class="horizontal-center-content">
        <template
          v-for="(value, key) in options"
          :key="key">
          <label>
            <input
              type="radio"
              v-model="fieldValue"
              :value="value"
            >
            {{ key }}
          </label>
        </template>
      </div>
    </td>
    <td>
      <button
        type="button"
        class="button circle-button btn-delete button-default"
        @click="$emit('remove')"
      />
    </td>
  </tr>
</template>

<script>
export default {
  props: {
    item: {
      type: Object,
      required: true
    },

    label: {
      type: String,
      default: 'object_tag'
    },

    modelValue: {
      type: Boolean,
      default: undefined
    },

    options: {
      type: Object,
      default: () => ({
        Empty: true,
        Filled: false
      })
    }
  },

  emits: [
    'update:modelValue',
    'remove'
  ],

  computed: {
    fieldValue: {
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

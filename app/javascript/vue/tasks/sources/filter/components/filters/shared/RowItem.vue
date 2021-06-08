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

    value: {
      type: Boolean,
      default: false
    },

    options: {
      type: Object,
      default: () => ({
        Empty: true,
        Filled: false
      })
    }
  },
  computed: {
    fieldValue: {
      get () {
        return this.value
      },
      set (value) {
        return this.$emit('input', value)
      }
    }
  }
}
</script>

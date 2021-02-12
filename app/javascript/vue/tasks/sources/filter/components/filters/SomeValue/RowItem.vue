<template>
  <tr>
    <td>
      <span v-html="item.name"/>
    </td>
    <td>
      <div class="horizontal-center-content">
        <label>
          <input
            type="radio"
            v-model="isEmpty"
            :value="true"
          >
          Empty
        </label>
        <label>
          <input
            type="radio"
            v-model="isEmpty"
            :value="false"
          >
          Filled
        </label>
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
    value: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    isEmpty: {
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

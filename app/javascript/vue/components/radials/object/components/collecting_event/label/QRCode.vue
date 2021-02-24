<template>
  <div>
    <div class="horizontal-right-content middle margin-medium-bottom">
      <label>Que to print
        <input
          class="que-input"
          :disabled="!(label.text && label.text.length)"
          size="5"
          v-model="label.total"
          type="number">
      </label>
      <a
        v-if="label.id && label.total > 0"
        target="blank"
        :href="`/tasks/labels/print_labels?label_id=${label.id}`">Preview
      </a>
    </div>
    <textarea
      class="full_width"
      :value="identifier.cached"
      disabled
      rows="12"
    />
  </div>
</template>

<script>
export default {
  props: {
    identifier: {
      type: Object,
      required: true
    },
    value: {
      type: Object,
      required: true
    }
  },
  computed: {
    label: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  created () {
    this.label.text = this.identifier.cached
  }
}
</script>

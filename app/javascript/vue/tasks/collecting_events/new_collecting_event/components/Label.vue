<template>
  <div>
    <h3>Label</h3>
    <ul class="no_bullets">
      <li
        v-for="(item, index) in labelTypes"
        :key="index">
        <label>
          <input
            v-model="type"
            :value="item.value"
            type="radio">
          {{ item.label }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  props: {
    modelValue: {
      type: String,
      default: undefined
    }
  },

  computed: {
    type: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  data () {
    return {
      labelTypes: [
        {
          label: 'None',
          value: undefined
        },
        {
          label: 'Text',
          value: 'Label'
        },
        {
          label: 'QR Code',
          value: 'Label::QrCode'
        },
        {
          label: 'Barcode',
          value: 'Label::Code128'
        }
      ]
    }
  }
}
</script>

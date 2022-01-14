<template>
  <div>
    <h3>Style</h3>
    <ul class="no_bullets">
      <li
        v-for="item in list"
        :key="item.value">
        <label
          @click="onSelectedStyle(item.value)">
          <input
            v-model="selectedStyle"
            :value="item.value"
            type="radio"
            name="style-selector">
          {{ item.label }}
        </label>
      </li>
    </ul>
    <div
      v-show="modelValue == 'custom_style'"
      class="separate-top">
      <custom-style @onNewStyle="$emit('onNewStyle', $event)"/>
    </div>
  </div>
</template>

<script>

import CustomStyle from './customStyle'

export default {
  components: { CustomStyle },

  props: {
    modelValue: {
      type: String,
      required: true
    }
  },

  emits: [
    'update:modelValue',
    'onNewStyle'
  ],

  data () {
    return {
      list: [{
        label: '4pt Insect (TAMU style)',
        value: 'ce_lbl_insect_compressed'
      },
      {
        label: '4pt Insect (NCSU style, uncompressed)',
        value: 'ce_lbl_insect'
      },
      {
        label: '4 dram Alchohol vial',
        value: 'ce_lbl_4_dram_ETOH'
      },
      {
        label: 'Custom style',
        value: 'custom_style'
      }]
    }
  },

  computed: {
    selectedStyle: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  methods: {
    onSelectedStyle (value) {
      this.$emit('update:modelValue', value)
    }
  }
}
</script>

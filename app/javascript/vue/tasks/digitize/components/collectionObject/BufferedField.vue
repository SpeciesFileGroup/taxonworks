<template>
  <div class="separate-right">
    <label>{{ title }}</label>
    <br>
    <div class="horizontal-left-content align-start">
      <textarea
        class="full_width separate-right"
        v-model="inputText"
        rows="5"/>
      <div>
        <lock-component
          v-model="locked"/>
        <button
          type="button"
          @click="bufferedDetermination = setInline(bufferedDetermination)"
          class="button button-default margin-small-top">
          Trim
        </button>
      </div>
    </div>
  </div>
</template>

<script>

import LockComponent from 'components/ui/VLock/index.vue'
import { stringInline } from 'helpers/strings'

export default {
  components: { LockComponent },

  props: {
    modelValue: {
      type: String,
      required: true
    },

    title: {
      type: String,
      required: true
    },

    lock: {
      type: Boolean,
      required: true
    }

  },

  emits: [
    'update:modelValue',
    'update:lock'
  ],

  computed: {
    inputText: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    },

    locked: {
      get () {
        return this.lock
      },
      set (value) {
        this.$emit('update:lock', value)
      }
    }
  },

  methods: {
    setInline (text) {
      this.inputText = stringInline(text)
    }
  }
}
</script>

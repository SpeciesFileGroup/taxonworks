<template>
  <div>
    <label>{{ title }}</label>
    <br>
    <div class="horizontal-left-content align-start">
      <textarea
        class="full_width separate-right"
        v-model="inputText"
        rows="5"
      />
      <div>
        <lock-component
          v-model="locked"
          class="margin-small-bottom"/>
        <v-btn
          type="button"
          @click="setInline(inputText)"
          color="primary">
          Trim
        </v-btn>
      </div>
    </div>
  </div>
</template>

<script>

import LockComponent from 'components/ui/VLock/index.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import { stringInline } from 'helpers/strings'

export default {
  components: {
    LockComponent,
    VBtn
  },

  props: {
    modelValue: {
      type: String,
      default: undefined
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

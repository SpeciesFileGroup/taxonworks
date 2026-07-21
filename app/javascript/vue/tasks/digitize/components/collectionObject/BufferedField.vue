<template>
  <div>
    <label>{{ title }}</label>
    <br />
    <div class="horizontal-left-content align-start">
      <textarea
        class="full_width separate-right"
        v-model="inputText"
        rows="5"
      />
      <div>
        <lock-component
          v-model="locked"
          class="margin-small-bottom"
        />
        <VBtn
          type="button"
          color="primary"
          variant="outline"
          @click="setInline(inputText || '')"
        >
          Trim
        </VBtn>
      </div>
    </div>
  </div>
</template>

<script setup>
import LockComponent from '@/components/ui/VLock/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { stringInline } from '@/helpers/strings'

const props = defineProps({
  title: {
    type: String,
    required: true
  }
})

const inputText = defineModel({
  type: String,
  default: undefined
})

const locked = defineModel('lock', {
  type: Boolean,
  required: true
})

function setInline(text) {
  inputText.value = stringInline(text)
}
</script>

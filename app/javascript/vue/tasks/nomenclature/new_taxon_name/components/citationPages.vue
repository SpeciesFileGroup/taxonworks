<template>
  <input
    v-model="inputValue"
    type="text"
    :disabled="disabled || !isCitationExist"
    class="w-20"
    placeholder="Pages"
    @input="updatePages(false)"
    @blur="updatePages(true)"
  />
</template>

<script setup>
import { computed, ref, watch } from 'vue'

const props = defineProps({
  citation: {
    type: Object,
    default: undefined
  },
  disabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['save', 'setPages'])

const pages = computed(() => props.citation?.pages ?? '')

const isCitationExist = computed(() => Boolean(props.citation))

const inputValue = ref(pages.value)

watch(pages, (value) => {
  inputValue.value = value
})

const updatePages = (immediate) => {
  if (props.disabled || !props.citation || inputValue.value === pages.value)
    return

  const eventName = immediate ? 'save' : 'setPages'
  const item = props.citation
  const newCitation = {
    id: item?.id ?? null,
    source_id: item?.source?.id ?? null,
    pages: inputValue.value
  }

  if (isCitationExist.value) {
    emit(eventName, newCitation)
  }
}
</script>

<template>
  <div>
    <div class="flex-separate margin-medium-bottom middle">
      <div>
        <button
          @click="copyLabel"
          class="button normal-input button-default"
          type="button"
          :disabled="isEmpty"
        >
          Copy verbatim label
        </button>
      </div>
      <div class="horizontal-right-content middle">
        <label
          >Que to print
          <input
            class="que-input"
            size="5"
            v-model="label.total"
            type="number"
          />
        </label>
        <a
          v-if="label.id && label.total > 0"
          target="blank"
          :href="`/tasks/labels/print_labels?label_id=${label.id}`"
          >Preview
        </a>
      </div>
    </div>
    <textarea
      class="full_width margin-small-bottom"
      v-model="label.text"
      cols="45"
      rows="12"
    />
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  collectingEvent: {
    type: Object,
    required: true
  }
})

const label = defineModel({
  type: Object,
  required: true
})

const isEmpty = computed(() => props.collectingEvent?.verbatim_label)

function copyLabel() {
  label.value.text = props.collectingEvent.verbatim_label
}
</script>

<template>
  <div>
    <div class="flex-separate margin-medium-bottom middle">
      <div>
        <button
          class="button normal-input button-default"
          type="button"
          :disabled="!identifier.cached"
          @click="setTextFromIdentifier"
        >
          Copy from CO Identifier
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
      class="full_width"
      :value="label.text"
      disabled
      rows="12"
    />
  </div>
</template>

<script setup>
const props = defineProps({
  identifier: {
    type: Object,
    required: true
  }
})

const label = defineModel({
  type: Object,
  required: true
})

function setTextFromIdentifier() {
  label.value.text = props.identifier.cached
}
</script>

<template>
  <tr>
    <td>
      <span v-html="item[label]"/>
    </td>
    <td>
      <div class="horizontal-center-content">
        <template
          v-for="(value, key) in options"
          :key="key">
          <label>
            <input
              type="radio"
              v-model="optionValue"
              :value="value"
            >
            {{ key }}
          </label>
        </template>
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

<script setup>

const props = defineProps({
  item: {
    type: Object,
    required: true
  },

  label: {
    type: String,
    default: 'name'
  },

  options: {
    type: Object,
    required: true
  }
})

const optionValue = defineModel()

const emits = defineEmits(['remove'])
</script>

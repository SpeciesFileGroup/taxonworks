<template>
  <tr>
    <td
      v-for="key in attributes"
      :key="key"
    >
      <input
        type="text"
        :value="item[key]"
        @change="
          (e) =>
            emit('update:attribute', {
              item: item,
              attribute: key,
              value: e.target.value
            })
        "
      />
    </td>
  </tr>
</template>

<script setup>
defineProps({
  attributes: {
    type: Array,
    default: () => []
  },

  item: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:attribute'])
</script>

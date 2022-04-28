<template>
  <div
    v-if="item"
    class="middle flex-separate"
  >
    <p v-html="item[label]" />
    <v-btn
      color="primary"
      circle
      @click="emit('unset')"
    >
      <v-icon
        name="trash"
        x-small
      />
    </v-btn>
  </div>
</template>
<script setup>
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

defineProps({
  item: {
    type: [String, Object],
    default: undefined
  },

  label: {
    type: String,
    default: 'object_tag'
  }
})
const emit = defineEmits(['unset'])

</script>

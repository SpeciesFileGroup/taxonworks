<template>
  <table class="table-striped">
    <thead>
      <tr>
        <th class="full_width">{{ title }}</th>
        <th />
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="citation in citations"
        :key="citation.uuid"
      >
        <td>
          {{ citation.label }}
        </td>
        <td>
          <VBtn
            circle
            :color="!!citation.id ? 'destroy' : 'primary'"
            @click="
              () => {
                emit('remove', citation)
              }
            "
          >
            <VIcon
              x-small
              name="trash"
            />
          </VBtn>
        </td>
      </tr>
    </tbody>
  </table>
</template>
<script setup>
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

defineProps({
  citations: {
    type: Array,
    required: true
  },

  title: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['remove'])
</script>

<template>
  <div>
    <div class="flex-separate flex-start">
      <ul class="no_bullets">
        <li>
          <label>
            <input
              type="radio"
              v-model="pattern.replace"
              :value="false"
            />
            Match
          </label>
        </li>
        <li>
          <label>
            <input
              type="radio"
              v-model="pattern.replace"
              :value="true"
            />
            Replace
          </label>
        </li>
      </ul>
      <VBtn
        color="primary"
        circle
        @click="emit('remove')"
      >
        <VIcon
          name="trash"
          x-small
        />
      </VBtn>
    </div>
    <div>
      <label class="d-block">Find</label>
      <input
        type="text"
        v-model="pattern.match"
      />
    </div>
    <div v-if="pattern.replace">
      <label class="d-block">Replace</label>
      <input
        type="text"
        v-model="pattern.value"
      />
    </div>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const pattern = defineModel({
  type: Object,
  required: true
})

const emit = defineEmits(['remove'])
</script>

<template>
  <div>
    <ul class="no_bullets">
      <li>
        <input
          type="radio"
          v-model="pattern.replace"
          :value="false"
        />
        Match
      </li>
      <li>
        <input
          type="radio"
          v-model="pattern.replace"
          :value="true"
        />
        Replace
      </li>
    </ul>
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
const pattern = defineModel({
  type: Object,
  required: true
})
</script>

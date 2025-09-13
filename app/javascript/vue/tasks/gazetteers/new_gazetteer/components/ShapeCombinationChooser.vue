<template>
  <fieldset class="chooser">
    <legend>Combine shapes by</legend>
    <ul class="no_bullets">
      <li>
        <label>
          <input
            type="radio"
            :value="true"
            v-model="operationIsUnion"
            checked
            :disabled="inputsDisabled"
          />
          Union
        </label>
      </li>

      <li>
        <label>
          <input
            type="radio"
            :value="false"
            v-model="operationIsUnion"
            :disabled="inputsDisabled"
          />
          Intersection
        </label>
      </li>
    </ul>
  </fieldset>
</template>

<script setup>
const props = defineProps({
  inputsDisabled: {
    type: Boolean,
    required: true
  }
})
const operationIsUnion = defineModel()
</script>

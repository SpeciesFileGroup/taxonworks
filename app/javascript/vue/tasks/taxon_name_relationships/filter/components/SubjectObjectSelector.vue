<template>
    <h3
      v-if="title"
    >
      {{  title }}
    </h3>

    <ul class="no_bullets">
      <li
        v-for="(value, key) in RELATION_TYPES"
        :key="key"
      >
        <label>
          <input
            :value="value.value"
            v-model="relationToRelationship"
            type="radio"
            name="relation_to_relationship"
          />
          {{ value.text }}
        </label>
      </li>
    </ul>
</template>

<script setup>

const RELATION_TYPES = {
  SubjectOrObject: {
    text: 'Subject or object of a relationship',
    value: ''
  },
  Subject: {
    text: 'Subject of a relationship',
    value: 'subject'
  },
  Object: {
    text: 'Object of a relationship',
    value: 'object'
  },
}

const props = defineProps({
  title: {
    type: String,
    default: ''
  }
})

const relationToRelationship = defineModel({
  type: String,
  default: ''
})
</script>

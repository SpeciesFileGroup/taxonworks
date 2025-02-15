<template>
  <FacetContainer>
    <h3>Relationship subject/object</h3>
    <ul class="no_bullets">
      <li
        v-for="(value, key) in RELATION_TYPES"
        :key="key"
      >
        <label>
          <input
            :value="value.value"
            v-model="params.relation_to_relationship"
            type="radio"
            name="relation_to_relationship"
          />
          {{ value.text }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const RELATION_TYPES = {
  Subject: {
    text: 'Subject of a relationship',
    value: 'subject'
  },
  Object: {
    text: 'Object of a relationship',
    value: 'object'
  },
  SubjectOrObject: {
    text: 'Subject or object of a relationship',
    value: 'either'
  },
  None: {
    text: 'None', // meaning don't apply this filter
    value: undefined
  }
}

const params = defineModel()
</script>

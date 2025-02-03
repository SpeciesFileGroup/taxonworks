<template>
  <div class="vue-filter-container flex-col gap-medium">
    <div class="panel content">
      <button
        v-help.filter.selectedPerson
        class="button normal-input button-default full_width"
        type="button"
        @click="emit('findPeople', params)"
      >
        Selected person
      </button>
      <button
        v-help.filter.matchPeople
        class="button normal-input button-default full_width margin-medium-top"
        type="button"
        :disabled="disabledMatch"
        @click="emit('matchPeople', params)"
      >
        Match people
      </button>
    </div>
    <FacetInProject v-model="params" />
    <FacetContainer>
      <h3>Person</h3>
      <FacetNameField
        title="Name"
        param="name"
        v-model="params"
      />
      <FacetNameField
        title="Last name"
        param="last_name"
        :disabled="params.levenshtein_cuttoff > 0"
        v-model="params"
      />
      <FacetNameField
        title="First name"
        param="first_name"
        :disabled="params.levenshtein_cuttoff > 0"
        v-model="params"
      />
    </FacetContainer>
    <FacetBetweenYear
      v-model="params"
      title="Active year"
      before-param="active_before_year"
      after-param="active_after_year"
    />
    <FacetBetweenYear
      v-model="params"
      title="Born year"
      before-param="born_before_year"
      after-param="born_after_year"
    />
    <FacetBetweenYear
      v-model="params"
      title="Died year"
      before-param="died_before_year"
      after-param="died_after_year"
    />
    <FacetLevenshteinCuttoff v-model="params" />
    <FacetRoleType
      v-model="params"
      title="Roles"
      param="role"
    />
    <keywords-component
      target="People"
      v-model="params"
    />
    <users-component v-model="params" />
  </div>
</template>

<script setup>
import KeywordsComponent from '@/components/Filter/Facets/shared/FacetTags.vue'
import UsersComponent from '@/components/Filter/Facets/shared/FacetHousekeeping/FacetHousekeeping.vue'
import FacetLevenshteinCuttoff from './Facets/FacetLevenshteinCuttoff.vue'
import FacetBetweenYear from '@/tasks/people/filter/components/Facet/FacetBetweenYear.vue'
import FacetRoleType from '@/tasks/people/filter/components/Facet/FacetRoles.vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import FacetNameField from './Facets/FacetNameField.vue'
import FacetInProject from './Facets/FacetInProject.vue'

const props = defineProps({
  disabledMatch: {
    type: Boolean,
    default: false
  }
})

const params = defineModel({ type: Object, required: true })

const emit = defineEmits(['findPeople', 'matchPeople'])
</script>

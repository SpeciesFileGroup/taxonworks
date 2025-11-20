<template>
  <div>
    <fieldset v-help.section.BibTeX.authors>
      <legend>Authors</legend>
      <SmartSelector
        model="people"
        :target="ROLE_SOURCE_AUTHOR"
        :klass="SOURCE"
        label="cached"
        :params="{ role_type: ROLE_SOURCE_AUTHOR }"
        :autocomplete-params="{
          roles: [ROLE_SOURCE_AUTHOR]
        }"
        :filter-ids="peopleIds"
        :autocomplete="false"
        @selected="addRole"
      >
        <template #header>
          <RolePicker
            ref="rolePicker"
            v-model="source.roles_attributes"
            :autofocus="false"
            :hidden-list="true"
            :filter-by-role="true"
            :role-type="ROLE_SOURCE_AUTHOR"
            @update:model-value="() => (source.isUnsaved = true)"
          />
        </template>
        <RolePicker
          v-model="source.roles_attributes"
          :create-form="false"
          :autofocus="false"
          :filter-by-role="true"
          :role-type="ROLE_SOURCE_AUTHOR"
          @update:model-value="() => (source.isUnsaved = true)"
        />
      </SmartSelector>
    </fieldset>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { ROLE_SOURCE_AUTHOR, SOURCE } from '@/constants'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import RolePicker from '@/components/role_picker.vue'

const source = defineModel({
  type: Object,
  required: true
})

const rolePicker = ref(null)

const peopleIds = computed(() =>
  source.value.roles_attributes
    .filter(
      (item) =>
        (item.person_id || item.person) &&
        !item._destroy &&
        item.type === ROLE_SOURCE_AUTHOR
    )
    .map((item) => item?.person_id || item.person.id)
)

function addRole(person) {
  rolePicker.value.addPerson(person)
  source.value.isUnsaved = true
}
</script>

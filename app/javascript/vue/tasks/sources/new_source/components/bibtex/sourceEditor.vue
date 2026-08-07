<template>
  <fieldset v-help.section.BibTeX.editors>
    <legend>Editors</legend>
    <SmartSelector
      model="people"
      label="cached"
      :target="ROLE_SOURCE_EDITOR"
      :klass="SOURCE"
      :filter-ids="peopleIds"
      :params="{ role_type: ROLE_SOURCE_EDITOR }"
      :autocomplete-params="{
        roles: [ROLE_SOURCE_EDITOR]
      }"
      :autocomplete="false"
      @selected="addRole"
    >
      <template #header>
        <RolePicker
          v-model="source.roles_attributes"
          ref="rolePicker"
          filter-by-role
          hidden-list
          :autofocus="false"
          :role-type="ROLE_SOURCE_EDITOR"
          @update:model-value="() => (source.isUnsaved = true)"
        />
      </template>
      <RolePicker
        v-model="source.roles_attributes"
        :create-form="false"
        :autofocus="false"
        filter-by-role
        :role-type="ROLE_SOURCE_EDITOR"
        @update:model-value="() => (source.isUnsaved = true)"
      />
    </SmartSelector>
  </fieldset>
</template>

<script setup>
import { computed, ref } from 'vue'
import { ROLE_SOURCE_EDITOR, SOURCE } from '@/constants'
import RolePicker from '@/components/role_picker.vue'
import SmartSelector from '@/components/ui/SmartSelector'

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
        item.type === ROLE_SOURCE_EDITOR
    )
    .map((item) => item?.person_id || item.person.id)
)

function addRole(person) {
  source.value.isUnsaved = true
  rolePicker.value.addPerson(person)
}
</script>

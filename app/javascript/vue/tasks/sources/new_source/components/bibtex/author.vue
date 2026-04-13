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
                    roles: [ROLE_SOURCE_AUTHOR],
                }"
                :filter-ids="peopleIds"
                :autocomplete="false"
                @selected="addRole"
            >
                <template #header>
                    <div class="horizontal-left-content gap-small">
                        <RolePicker
                            ref="rolePicker"
                            v-model="source.roles_attributes"
                            :autofocus="false"
                            :hidden-list="true"
                            :filter-by-role="true"
                            :role-type="ROLE_SOURCE_AUTHOR"
                            @update:model-value="
                                () => (source.isUnsaved = true)
                            "
                        />
                        <VBtn
                            v-if="source.author"
                            color="primary"
                            circle
                            title="Match authors from BibTeX string"
                            @click="showMatchModal = true"
                        >
                            ↔
                        </VBtn>
                    </div>
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

        <AuthorMatchModal
            v-if="showMatchModal"
            :author-string="source.author"
            :existing-roles="authorRoles"
            @close="showMatchModal = false"
            @apply="applyMatchedAuthors"
        />
    </div>
</template>

<script setup>
import { computed, ref } from "vue";
import { ROLE_SOURCE_AUTHOR, SOURCE } from "@/constants";
import SmartSelector from "@/components/ui/SmartSelector.vue";
import RolePicker from "@/components/role_picker.vue";
import VBtn from "@/components/ui/VBtn/index.vue";
import AuthorMatchModal from "./AuthorMatchModal.vue";

const source = defineModel({
    type: Object,
    required: true,
});

const rolePicker = ref(null);
const showMatchModal = ref(false);

const authorRoles = computed(() =>
    source.value.roles_attributes.filter(
        (item) => item.type === ROLE_SOURCE_AUTHOR,
    ),
);

const peopleIds = computed(() =>
    authorRoles.value
        .filter((item) => (item.person_id || item.person) && !item._destroy)
        .map((item) => item?.person_id || item.person.id),
);

function addRole(person) {
    rolePicker.value.addPerson(person);
    source.value.isUnsaved = true;
}

function applyMatchedAuthors(people) {
    for (const person of people) {
        rolePicker.value.addPerson(person);
    }
    source.value.isUnsaved = true;
    showMatchModal.value = false;
}
</script>

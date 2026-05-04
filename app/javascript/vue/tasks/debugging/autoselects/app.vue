<template>
    <div id="autoselects_task">
        <h1>Autoselect Playground</h1>
        <p>
            A prototype task for testing autoselect field behavior across
            models. <em> Use `!?` within an input to get started.</em>
        </p>

        <section class="separate-bottom">
            <label>
                Level delay (ms):
                <input
                    v-model.number="levelDelay"
                    type="number"
                    min="0"
                    step="50"
                    style="width: 80px"
                />
            </label>
        </section>

        <section
            v-for="model in registeredModels"
            :key="model.url + model.id"
            class="separate-bottom"
        >
            <h2>{{ model.label }}</h2>
            <AutoselectField
                :id="model.id"
                :url="model.url"
                :param="model.param"
                :placeholder="`Search ${model.label}...`"
                :level-delay="levelDelay"
                :new-record-component="model.newRecordComponent ?? null"
                :preferences-options-component="
                    model.preferencesOptionsComponent ?? null
                "
                :reset-on-select="model.resetOnSelect ?? false"
                v-model="selectedItems[model.id]"
                @select="onSelect(model.label, $event)"
            />
            <div
                v-if="selectedItems[model.id]?.global_id"
                class="autoselects-task__radial"
            >
                <RadialNavigator
                    :global-id="selectedItems[model.id].global_id"
                />
            </div>
            <pre v-if="selections[model.label]">{{
                JSON.stringify(selections[model.label], null, 2)
            }}</pre>
        </section>

        <p v-if="registeredModels.length === 0" class="feedback">
            No models registered yet. Run
            <code
                >rails generate taxon_works:autoselect &lt;model_name&gt;</code
            >
            to add one.
        </p>
    </div>
</template>

<script setup>
import { ref } from "vue";
import AutoselectField from "@/components/ui/AutoselectField.vue";
import RadialNavigator from "@/components/radials/navigation/radial.vue";
import OtuNewModal from "@/components/ui/AutoselectField/OtuNewModal.vue";
import TaxonNameNewModal from "@/components/ui/AutoselectField/TaxonNameNewModal.vue";
import ColDatasetPicker from "@/components/ui/AutoselectField/ColDatasetPicker.vue";

// Models are registered here by the autoselect generator.
// id: stable unique identifier used for preferences storage and the DOM id attribute
// newRecordComponent: Vue component to mount when !n is typed (null = disabled)
// preferencesOptionsComponent: Vue component rendered inside PreferencesModal for model-specific options
const registeredModels = ref([
    {
        id: "playground-taxon-name-1",
        url: "/taxon_names/autoselect",
        param: "taxon_name_id",
        label: "TaxonName (1)",
        newRecordComponent: TaxonNameNewModal,
        preferencesOptionsComponent: ColDatasetPicker,
        resetOnSelect: true,
    },
    {
        id: "playground-taxon-name-2",
        url: "/taxon_names/autoselect",
        param: "taxon_name_id",
        label: "TaxonName (2)",
        newRecordComponent: TaxonNameNewModal,
        preferencesOptionsComponent: ColDatasetPicker,
        resetOnSelect: true,
    },
    {
        id: "playground-otu",
        url: "/otus/autoselect",
        param: "otu_id",
        label: "OTU",
        newRecordComponent: OtuNewModal,
        preferencesOptionsComponent: ColDatasetPicker,
        resetOnSelect: true,
    },
]);

const levelDelay = ref(500);

// Full selected item per model id (includes global_id for radial)
const selectedItems = ref({});

const selections = ref({});

function onSelect(label, values) {
    selections.value[label] = values;
}
</script>

<style scoped>
.autoselects-task__radial {
    display: inline-block;
    margin-top: 4px;
}
</style>

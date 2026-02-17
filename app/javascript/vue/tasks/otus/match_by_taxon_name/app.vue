<template>
    <div class="margin-medium-top">
        <VSpinner v-if="isProcessing" full-screen legend="Matching names..." />

        <InputPanel v-if="stage === 'input'" @submit="handleDataSubmit" />

        <template v-if="stage === 'results'">
            <div class="flex-row align-start gap-medium">
                <div class="flex-col gap-medium left-column">
                    <div class="panel content">
                        <div class="flex-row flex-separate middle">
                            <VBtn
                                color="primary"
                                medium
                                :disabled="!rows.length"
                                @click="runMatch({ matchAll: true })"
                            >
                                Match
                            </VBtn>
                            <VBtn circle color="primary" @click="reset">
                                <VIcon x-small name="reset" />
                            </VBtn>
                        </div>
                    </div>

                    <MatchOptionsPanel
                        v-model:scope-taxon-name-id="scopeTaxonNameId"
                        v-model:levenshtein-distance="levenshteinDistance"
                        v-model:try-without-subgenus="tryWithoutSubgenus"
                        v-model:resolve-synonyms="resolveSynonyms"
                        v-model:modifiers="modifiers"
                        :filter-result-link="filterResultLink"
                        @clear-all="clearAllMatches"
                        @update-options="runMatch"
                    />
                </div>

                <div class="flex-row align-start gap-medium full_width">
                    <div class="full_width">
                        <SummaryBar v-if="rows.length" :rows="rows" />

                        <ResultTable
                            :rows="rows"
                            :csv-data="csvData"
                            @update-row="handleRowUpdate"
                            @create-otu="handleCreateOtu"
                            @scroll-to-row="scrollToRow"
                        />
                    </div>
                </div>
            </div>
        </template>
    </div>
</template>

<script setup>
import { ref, computed, nextTick, onMounted } from "vue";
import { TaxonName, Otu } from "@/routes/endpoints";
import VSpinner from "@/components/ui/VSpinner.vue";
import VBtn from "@/components/ui/VBtn/index.vue";
import VIcon from "@/components/ui/VIcon/index.vue";
import ButtonClipboard from "@/components/ui/Button/ButtonClipboard.vue";
import InputPanel from "./components/InputPanel.vue";
import ResultTable from "./components/ResultTable.vue";
import SummaryBar from "./components/SummaryBar.vue";
import MatchOptionsPanel from "./components/MatchOptionsPanel.vue";

defineOptions({
    name: "MatchOtuByTaxonName",
});

const MAX_ROWS = 1000;

const stage = ref("input");
const isProcessing = ref(false);
const rows = ref([]);
const csvData = ref(null);

const scopeTaxonNameId = ref(null);
const levenshteinDistance = ref(0);
const tryWithoutSubgenus = ref(false);
const resolveSynonyms = ref(false);
const filterResultLink = ref(false);

onMounted(() => {
    const urlParams = new URLSearchParams(window.location.search);
    const taxonNameId = urlParams.get("taxon_name_id");

    if (taxonNameId) {
        scopeTaxonNameId.value = parseInt(taxonNameId);
        filterResultLink.value = true;
    }
});
const modifiers = ref([
    { active: false, pattern: "^(\\S*\\s+\\S*).*", replacement: "$1" },
    { active: false, pattern: "", replacement: "" },
]);

const checkedRowIndices = computed(() =>
    rows.value.map((r, i) => (r.selected ? i : -1)).filter((i) => i >= 0),
);

function handleDataSubmit({ names, csv }) {
    csvData.value = csv;

    rows.value = names.slice(0, MAX_ROWS).map((name, index) => {
        const isEmpty = !name || !name.trim();
        return {
            index,
            scientificName: isEmpty ? "" : name,
            matchString: "",
            taxonName: null,
            taxonNameId: null,
            otus: [],
            selectedOtuId: null,
            ambiguous: false,
            matched: false,
            selected: false,
            isEmpty,
            csvRow: csv ? csv.rows[index] : null,
        };
    });

    stage.value = "results";

    nextTick(() => {
        runMatch({ matchAll: true });
    });
}

function applyModifiers(name) {
    let result = name;

    for (const modifier of modifiers.value) {
        if (!modifier.active || !modifier.pattern) continue;

        try {
            const regex = new RegExp(modifier.pattern, "g");
            result = result.replace(regex, modifier.replacement || "");
        } catch {
            // Invalid regex, skip
        }
    }

    return result.trim();
}

function computeMatchStrings() {
    const hasActiveModifier = modifiers.value.some(
        (m) => m.active && m.pattern,
    );

    rows.value.forEach((row) => {
        if (row.isEmpty) return;

        if (hasActiveModifier && row.selected) {
            row.matchString = applyModifiers(row.scientificName);
        } else if (!row.selected) {
            // Don't change matchString for unselected rows
        } else {
            row.matchString = "";
        }
    });
}

async function runMatch({ matchAll = false } = {}) {
    computeMatchStrings();
    syncAllDuplicates();

    const checkedRows = rows.value.filter((r) => r.selected && !r.isEmpty);
    const selectedRows = matchAll
        ? rows.value.filter((r) => !r.isEmpty)
        : checkedRows;
    if (!selectedRows.length) return;

    const nameMap = new Map();

    selectedRows.forEach((row) => {
        const effectiveName = row.matchString || row.scientificName;
        if (!nameMap.has(effectiveName)) {
            nameMap.set(effectiveName, []);
        }
        nameMap.get(effectiveName).push(row);
    });

    const uniqueNames = [...nameMap.keys()];

    isProcessing.value = true;

    try {
        const { body } = await TaxonName.match({
            names: uniqueNames,
            levenshtein_distance: levenshteinDistance.value,
            taxon_name_id: scopeTaxonNameId.value,
            resolve_synonyms: resolveSynonyms.value ? "true" : "false",
            try_without_subgenus: tryWithoutSubgenus.value ? "true" : "false",
        });

        body.forEach((result) => {
            const matchedRows = nameMap.get(result.scientific_name);
            if (!matchedRows) return;

            matchedRows.forEach((row) => {
                row.taxonName = result.taxon_name;
                row.taxonNameId = result.taxon_name_id;
                row.otus = result.otus || [];
                row.selectedOtuId = result.otus?.length
                    ? result.otus[0].id
                    : null;
                row.ambiguous = result.ambiguous;
                row.matched = result.matched;
            });
        });
    } catch (e) {
        TW.workbench.alert.create(
            "Error matching names. See console for details.",
            "error",
        );
        console.error(e);
    } finally {
        syncAllDuplicates();
        isProcessing.value = false;
    }
}

function handleRowUpdate({ index, field, value }) {
    const row = rows.value[index];
    if (!row) return;

    if (field === "taxonName") {
        row.taxonName = value;
        row.taxonNameId = value?.id || null;
        row.otus = [];
        row.selectedOtuId = null;
        row.ambiguous = false;
        row.matched = !!value;

        if (value) {
            loadOtusForTaxonName(value.id, row);
        }

        syncDuplicateRows(row);
    } else if (field === "matchString") {
        row.matchString = value;
    } else if (field === "selected") {
        row.selected = value;
    } else if (field === "selectedOtuId") {
        row.selectedOtuId = value;
        syncDuplicateRows(row);
    }
}

async function loadOtusForTaxonName(taxonNameId, row) {
    try {
        const { body } = await TaxonName.otus(taxonNameId);
        row.otus = body.map((o) => ({
            id: o.id,
            name: o.name,
            taxon_name_id: o.taxon_name_id,
            object_label: o.object_label,
        }));
        if (row.otus.length) {
            row.selectedOtuId = row.otus[0].id;
        }
        syncDuplicateRows(row);
    } catch (e) {
        console.error("Failed to load OTUs:", e);
    }
}

async function handleCreateOtu({ index }) {
    const row = rows.value[index];
    if (!row?.taxonNameId) return;

    try {
        const { body } = await Otu.create({
            otu: { taxon_name_id: row.taxonNameId },
        });
        const newOtu = {
            id: body.id,
            name: body.name,
            taxon_name_id: body.taxon_name_id,
            object_label: body.object_label,
        };

        row.otus.push(newOtu);
        row.selectedOtuId = newOtu.id;

        syncDuplicateRows(row);
        TW.workbench.alert.create("OTU created successfully.", "notice");
    } catch (e) {
        TW.workbench.alert.create("Failed to create OTU.", "error");
        console.error(e);
    }
}

function syncDuplicateRows(sourceRow) {
    const sourceName = sourceRow.matchString || sourceRow.scientificName;

    rows.value.forEach((row) => {
        if (row.index === sourceRow.index) return;

        const rowName = row.matchString || row.scientificName;
        if (rowName === sourceName) {
            row.taxonName = sourceRow.taxonName;
            row.taxonNameId = sourceRow.taxonNameId;
            row.otus = sourceRow.otus;
            row.selectedOtuId = sourceRow.selectedOtuId;
            row.ambiguous = sourceRow.ambiguous;
            row.matched = sourceRow.matched;
        }
    });
}

// After match operations, ensure all rows with identical effective names
// share the same match data from the first occurrence (the actionable row).
function syncAllDuplicates() {
    const seen = new Map();

    rows.value.forEach((row) => {
        if (row.isEmpty) return;

        const name = row.matchString || row.scientificName;
        if (!seen.has(name)) {
            seen.set(name, row);
        } else {
            const source = seen.get(name);
            row.taxonName = source.taxonName;
            row.taxonNameId = source.taxonNameId;
            row.otus = source.otus;
            row.selectedOtuId = source.selectedOtuId;
            row.ambiguous = source.ambiguous;
            row.matched = source.matched;
            row.selected = false;
        }
    });
}

function clearAllMatches() {
    rows.value.forEach((row) => {
        row.taxonName = null;
        row.taxonNameId = null;
        row.otus = [];
        row.selectedOtuId = null;
        row.ambiguous = false;
        row.matched = false;
        row.matchString = "";
    });
}

function scrollToRow(index) {
    const el = document.querySelector(`[data-row-index="${index}"]`);
    if (el) {
        el.scrollIntoView({ behavior: "smooth", block: "center" });
        el.classList.add("highlight-row");
        setTimeout(() => el.classList.remove("highlight-row"), 2000);
    }
}

function reset() {
    stage.value = "input";
    rows.value = [];
    csvData.value = null;
    scopeTaxonNameId.value = null;
    levenshteinDistance.value = 0;
    tryWithoutSubgenus.value = false;
    resolveSynonyms.value = false;
    modifiers.value = [
        { active: false, pattern: "^(\\S*\\s+\\S*).*", replacement: "$1" },
        { active: false, pattern: "", replacement: "" },
    ];
}
</script>

<style scoped>
:deep(.highlight-row) {
    animation: highlight-fade 2s ease-out;
}

@keyframes highlight-fade {
    0% {
        background-color: #ffffcc;
    }
    100% {
        background-color: transparent;
    }
}
</style>

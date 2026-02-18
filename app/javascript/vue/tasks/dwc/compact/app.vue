<template>
    <div class="dwc-compact-task">
        <CompactForm
            :is-loading="isLoading"
            @compact="handleCompact"
            @preview="handlePreview"
        />

        <div v-if="errors.length" class="dwc-compact-errors">
            <h3>Errors / Warnings ({{ errors.length }})</h3>
            <ul>
                <li
                    v-for="(error, index) in errors"
                    :key="index"
                    :class="{ 'dwc-compact-warning': error.type === 'warning' }"
                >
                    <strong>{{ error.type }}:</strong> {{ error.message }}
                    <span v-if="error.values">
                        — values: {{ error.values.join(", ") }}</span
                    >
                </li>
            </ul>
        </div>

        <template v-if="rows.length">
            <SummaryPanel :rows="rows" :meta="meta" />

            <div class="dwc-compact-charts">
                <ChartSexCounts :rows="rows" />
                <ChartLifeStageCounts :rows="rows" />
                <ChartByYear :rows="rows" />
                <ChartByScientificName :rows="rows" />
                <ChartCalendarDay :rows="rows" />
            </div>

            <CompactTable :headers="headers" :rows="rows" />
        </template>

        <VSpinner v-if="isLoading" legend="Loading..." />
    </div>
</template>

<script setup>
import { ref } from "vue";
import { DwcOcurrence } from "@/routes/endpoints";
import { LinkerStorage } from "@/shared/Filter/utils";
import VSpinner from "@/components/ui/VSpinner.vue";
import CompactForm from "./components/CompactForm.vue";
import SummaryPanel from "./components/SummaryPanel.vue";
import ChartSexCounts from "./components/ChartSexCounts.vue";
import ChartLifeStageCounts from "./components/ChartLifeStageCounts.vue";
import ChartCalendarDay from "./components/ChartCalendarDay.vue";
import ChartByYear from "./components/ChartByYear.vue";
import ChartByScientificName from "./components/ChartByScientificName.vue";
import CompactTable from "./components/CompactTable.vue";

const isLoading = ref(false);
const headers = ref([]);
const rows = ref([]);
const errors = ref([]);
const meta = ref({});

function getStoredParams() {
    const stored = LinkerStorage.getParameters();

    if (stored) {
        LinkerStorage.removeParameters();
        return stored;
    }

    return null;
}

async function requestCompact(params, preview = false) {
    isLoading.value = true;
    errors.value = [];

    try {
        const response = await DwcOcurrence.compact({
            ...params,
            preview,
        });

        headers.value = response.body.headers;
        rows.value = response.body.rows;
        errors.value = response.body.errors || [];
        meta.value = response.body.meta || {};
    } catch (e) {
        errors.value = [
            { type: "error", message: e.message || "Request failed" },
        ];
    } finally {
        isLoading.value = false;
    }
}

function handleCompact(params) {
    requestCompact(params, false);
}

function handlePreview(params) {
    requestCompact(params, true);
}

const storedParams = getStoredParams();
if (storedParams) {
    requestCompact(storedParams, false);
}
</script>

<style scoped>
.dwc-compact-task {
    padding: 1em;
    max-width: 100%;
}

.dwc-compact-errors {
    margin: 1em 0;
    padding: 0.5em 1em;
    background-color: #fff3cd;
    border: 1px solid #ffc107;
    border-radius: 4px;
    max-height: 300px;
    overflow-y: auto;
}

.dwc-compact-errors ul {
    list-style: none;
    padding: 0;
}

.dwc-compact-errors li {
    padding: 0.25em 0;
    border-bottom: 1px solid #eee;
    color: #c62828;
}

.dwc-compact-warning {
    color: #e65100 !important;
}

.dwc-compact-charts {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
    gap: 1em;
    margin: 1em 0;
}
</style>

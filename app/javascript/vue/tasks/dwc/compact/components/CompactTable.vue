<template>
    <div class="dwc-compact-table panel content">
        <h3>Data ({{ rows.length }} rows)</h3>

        <div class="dwc-compact-table-actions">
            <button
                class="button normal-input button-default"
                @click="downloadTsv"
            >
                Download TSV
            </button>
            <button
                v-if="rows.length <= 1000"
                class="button normal-input button-default"
                @click="copyTableToClipboard"
            >
                Copy table to clipboard
            </button>
        </div>

        <div class="dwc-compact-table-scroll">
            <table class="vue-table">
                <thead>
                    <tr>
                        <th
                            v-for="header in headers"
                            :key="header"
                            class="dwc-compact-th"
                        >
                            <span @click="toggleSort(header)">
                                {{ displayHeader(header) }}
                                <span
                                    v-if="sortColumn === header"
                                    class="sort-indicator"
                                >
                                    {{ sortDirection === "asc" ? "▲" : "▼" }}
                                </span>
                            </span>
                            <VBtn
                                v-if="header === 'catalogNumber'"
                                color="primary"
                                circle
                                title="Copy catalogNumber column to clipboard"
                                @click.stop="copyCatalogNumberColumn"
                            >
                                <VIcon
                                    name="clip"
                                    title="Copy catalogNumber column to clipboard"
                                    x-small
                                />
                            </VBtn>
                        </th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="(row, index) in sortedRows" :key="index">
                        <td
                            v-for="header in headers"
                            :key="header"
                            class="dwc-compact-td"
                            :title="row[header]"
                        >
                            {{ row[header] }}
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</template>

<script setup>
import { ref, computed } from "vue";
import VBtn from "@/components/ui/VBtn/index.vue";
import VIcon from "@/components/ui/VIcon/index.vue";

const HEADER_DISPLAY = {
    dwcClass: "class",
};

const props = defineProps({
    headers: {
        type: Array,
        required: true,
    },
    rows: {
        type: Array,
        required: true,
    },
});

const sortColumn = ref(null);
const sortDirection = ref("asc");

function displayHeader(header) {
    return HEADER_DISPLAY[header] || header;
}

function toggleSort(header) {
    if (sortColumn.value === header) {
        sortDirection.value = sortDirection.value === "asc" ? "desc" : "asc";
    } else {
        sortColumn.value = header;
        sortDirection.value = "asc";
    }
}

const sortedRows = computed(() => {
    if (!sortColumn.value) return props.rows;

    const col = sortColumn.value;
    const dir = sortDirection.value === "asc" ? 1 : -1;

    return [...props.rows].sort((a, b) => {
        const valA = a[col] ?? "";
        const valB = b[col] ?? "";

        const numA = Number(valA);
        const numB = Number(valB);

        if (!isNaN(numA) && !isNaN(numB) && valA !== "" && valB !== "") {
            return (numA - numB) * dir;
        }

        return String(valA).localeCompare(String(valB)) * dir;
    });
});

function generateTsvString() {
    const headerLine = props.headers.map(displayHeader).join("\t");
    const dataLines = sortedRows.value.map((row) =>
        props.headers.map((h) => row[h] ?? "").join("\t"),
    );

    return [headerLine, ...dataLines].join("\n");
}

function downloadTsv() {
    const tsv = generateTsvString();
    const blob = new Blob([tsv], { type: "text/tab-separated-values" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");

    link.href = url;
    link.download = `dwc_compact_${new Date().toISOString().slice(0, 10)}.tsv`;
    link.click();
    URL.revokeObjectURL(url);
}

function copyTableToClipboard() {
    const tsv = generateTsvString();
    navigator.clipboard
        .writeText(tsv)
        .then(() => {
            TW.workbench.alert.create("Copied to clipboard", "notice");
        })
        .catch(() => {});
}

function copyCatalogNumberColumn() {
    const values = sortedRows.value
        .map((row) => row.catalogNumber)
        .filter(Boolean)
        .join("\n");

    navigator.clipboard
        .writeText(values)
        .then(() => {
            TW.workbench.alert.create("Copied to clipboard", "notice");
        })
        .catch(() => {});
}
</script>

<style scoped>
.dwc-compact-table-actions {
    margin-bottom: 0.5em;
    display: flex;
    gap: 0.5em;
}

.dwc-compact-table-scroll {
    overflow-x: auto;
    max-height: 600px;
    overflow-y: auto;
}

.dwc-compact-th {
    cursor: pointer;
    user-select: none;
    white-space: nowrap;
}

.dwc-compact-th:hover {
    background-color: #eee;
}

.sort-indicator {
    font-size: 0.7em;
    margin-left: 0.25em;
}

.dwc-compact-td {
    max-width: 200px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
</style>

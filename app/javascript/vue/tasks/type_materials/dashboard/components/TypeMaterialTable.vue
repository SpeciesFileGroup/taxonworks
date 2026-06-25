<template>
    <div class="panel content type-material-table">
        <h3>
            Type material ({{ rows.length }} rows<span v-if="truncated"> — truncated</span>)
        </h3>

        <div class="type-material-table-scroll">
            <table class="vue-table">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Object</th>
                        <th
                            v-for="column in sortableColumns"
                            :key="column.key"
                            class="type-material-th"
                            @click="toggleSort(column.key)"
                        >
                            {{ column.label }}
                            <span
                                v-if="sortColumn === column.key"
                                class="sort-indicator"
                            >{{ sortDirection === "asc" ? "▲" : "▼" }}</span>
                        </th>
                        <th
                            v-for="type in typeTypes"
                            :key="`tt-${type}`"
                            class="type-material-th"
                            @click="toggleSort(`tt:${type}`)"
                        >
                            {{ type }}
                            <span
                                v-if="sortColumn === `tt:${type}`"
                                class="sort-indicator"
                            >{{ sortDirection === "asc" ? "▲" : "▼" }}</span>
                        </th>
                        <th>Source</th>
                    </tr>
                </thead>
                <tbody>
                    <tr
                        v-for="row in pageRows"
                        :key="row.type_material_id"
                    >
                        <td>
                            <RadialNavigation :global-id="row.taxon_name_global_id" />
                        </td>
                        <td>
                            <RadialNavigation :global-id="row.collection_object_global_id" />
                        </td>
                        <td>
                            <span v-html="row.cached_original_combination" />
                        </td>
                        <td>{{ row.cached_author }}</td>
                        <td>{{ row.year }}</td>
                        <td>{{ row.repository_acronym }}</td>
                        <td
                            v-for="type in typeTypes"
                            :key="`td-${row.type_material_id}-${type}`"
                            class="type-material-count"
                        >
                            {{ row.individuals_by_type[type] || "" }}
                        </td>
                        <td>
                            <a
                                v-if="row.source_id"
                                :href="`/sources/${row.source_id}`"
                                target="_blank"
                                rel="noopener"
                            >Source</a>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>

        <div
            v-if="pageCount > 1"
            class="type-material-pagination"
        >
            <button
                class="button normal-input button-default"
                :disabled="page === 1"
                @click="page--"
            >
                Previous
            </button>
            <span>Page {{ page }} / {{ pageCount }}</span>
            <button
                class="button normal-input button-default"
                :disabled="page === pageCount"
                @click="page++"
            >
                Next
            </button>
        </div>
    </div>
</template>

<script setup>
import { ref, computed, watch } from "vue";
import RadialNavigation from "@/components/radials/navigation/radial.vue";

const PER_PAGE = 50;

const props = defineProps({
    typeTypes: {
        type: Array,
        default: () => [],
    },
    rows: {
        type: Array,
        default: () => [],
    },
    truncated: {
        type: Boolean,
        default: false,
    },
});

const sortableColumns = [
    { key: "cached_original_combination", label: "Original combination" },
    { key: "cached_author", label: "Author" },
    { key: "year", label: "Year" },
    { key: "repository_acronym", label: "Repository" },
];

// Default order matches the controller (cached_original_combination ascending).
const sortColumn = ref("cached_original_combination");
const sortDirection = ref("asc");
const page = ref(1);

function toggleSort(key) {
    if (sortColumn.value === key) {
        sortDirection.value = sortDirection.value === "asc" ? "desc" : "asc";
    } else {
        sortColumn.value = key;
        sortDirection.value = "asc";
    }
}

function sortValue(row, key) {
    if (key.startsWith("tt:")) {
        return row.individuals_by_type[key.slice(3)] || 0;
    }
    return row[key];
}

const sortedRows = computed(() => {
    const direction = sortDirection.value === "asc" ? 1 : -1;
    const key = sortColumn.value;

    return [...props.rows].sort((a, b) => {
        const va = sortValue(a, key);
        const vb = sortValue(b, key);

        if (va == null && vb == null) return 0;
        if (va == null) return 1;
        if (vb == null) return -1;

        if (typeof va === "number" && typeof vb === "number") {
            return (va - vb) * direction;
        }
        return String(va).localeCompare(String(vb)) * direction;
    });
});

const pageCount = computed(() =>
    Math.max(1, Math.ceil(sortedRows.value.length / PER_PAGE)),
);

const pageRows = computed(() => {
    const start = (page.value - 1) * PER_PAGE;
    return sortedRows.value.slice(start, start + PER_PAGE);
});

watch([sortColumn, sortDirection, () => props.rows], () => {
    page.value = 1;
});
</script>

<style scoped>
.type-material-table-scroll {
    overflow-x: auto;
    max-height: 600px;
    overflow-y: auto;
}

.type-material-th {
    cursor: pointer;
    white-space: nowrap;
}

.type-material-count {
    text-align: right;
}

.type-material-pagination {
    display: flex;
    align-items: center;
    gap: 1em;
    margin-top: 1em;
}

.sort-indicator {
    font-size: 0.75em;
}
</style>

<template>
    <table class="full_width">
        <thead>
            <tr>
                <th @click="sortBy('verbatim_author')">
                    Author
                    <span v-if="sortColumn === 'verbatim_author'">
                        {{ sortDirection === "asc" ? "▲" : "▼" }}
                    </span>
                </th>
                <th @click="sortBy('year_of_publication')">
                    Year
                    <span v-if="sortColumn === 'year_of_publication'">
                        {{ sortDirection === "asc" ? "▲" : "▼" }}
                    </span>
                </th>
                <th>Copy</th>
                <th @click="sortBy('record_count')">
                    Count
                    <span v-if="sortColumn === 'record_count'">
                        {{ sortDirection === "asc" ? "▲" : "▼" }}
                    </span>
                </th>
                <th>New Source</th>
                <th>Filter</th>
                <th>Taxon names</th>
                <th>Batch Cite</th>
            </tr>
        </thead>
        <tbody>
            <tr
                v-for="row in sortedData"
                :key="`${row.verbatim_author}-${row.year_of_publication}`"
                :data-author="row.verbatim_author"
                :data-year="row.year_of_publication"
            >
                <td>{{ row.verbatim_author }}</td>
                <td>{{ row.year_of_publication }}</td>
                <td class="copy-cell">
                    <VBtn
                        color="primary"
                        circle
                        title="Copy author and year to clipboard"
                        @click="
                            copyToClipboard(
                                row.verbatim_author,
                                row.year_of_publication,
                            )
                        "
                    >
                        <VIcon name="clip" x-small />
                    </VBtn>
                </td>
                <td
                    class="count-cell"
                    :style="{ backgroundColor: row.heat_color }"
                >
                    {{ row.record_count }}
                </td>
                <td>
                    <a :href="newSourceUrl" target="_blank"> New Source </a>
                </td>
                <td>
                    <a
                        :href="
                            filterUrl(
                                row.verbatim_author,
                                row.year_of_publication,
                            )
                        "
                        target="_blank"
                    >
                        Filter TaxonNames
                    </a>
                </td>
                <td>
                    <VBtn
                        color="primary"
                        medium
                        @click="
                            $emit(
                                'preview',
                                row.verbatim_author,
                                row.year_of_publication,
                            )
                        "
                    >
                        Taxon names
                    </VBtn>
                </td>
                <td class="batch-cite-cell">
                    <VBtn
                        v-if="!row.isCited && !row.isPending"
                        color="primary"
                        medium
                        @click="
                            $emit(
                                'cite',
                                row.verbatim_author,
                                row.year_of_publication,
                            )
                        "
                    >
                        Cite
                    </VBtn>
                    <span v-else-if="row.isPending" class="pending-text">
                        Creating citations...
                    </span>
                    <span v-else class="success-text">
                        ✓ Citations created
                    </span>
                </td>
            </tr>
        </tbody>
    </table>
</template>

<script setup>
import { ref, computed } from "vue";
import { RouteNames } from "@/routes/routes";
import useStore from "../store/store";
import VBtn from "@/components/ui/VBtn/index.vue";
import VIcon from "@/components/ui/VIcon/index.vue";

const store = useStore();

const sortColumn = ref("year_of_publication");
const sortDirection = ref("desc");

defineEmits(["cite", "preview"]);

const sortedData = computed(() => {
    const data = [...store.authorYearData];

    data.sort((a, b) => {
        let aVal = a[sortColumn.value];
        let bVal = b[sortColumn.value];

        // Handle null/undefined
        if (aVal == null && bVal == null) return 0;
        if (aVal == null) return 1;
        if (bVal == null) return -1;

        // Compare values
        if (aVal < bVal) return sortDirection.value === "asc" ? -1 : 1;
        if (aVal > bVal) return sortDirection.value === "asc" ? 1 : -1;
        return 0;
    });

    return data;
});

const newSourceUrl = computed(() => {
    return RouteNames.NewSource;
});

function sortBy(column) {
    if (sortColumn.value === column) {
        sortDirection.value = sortDirection.value === "asc" ? "desc" : "asc";
    } else {
        sortColumn.value = column;
        sortDirection.value = "asc";
    }
}

function filterUrl(author, year) {
    const params = new URLSearchParams({
        author: author,
        author_exact: true,
        year_of_publication: year,
    });
    return `${RouteNames.FilterNomenclature}?${params.toString()}`;
}

function copyToClipboard(author, year) {
    const text = `${author} ${year}`;
    navigator.clipboard.writeText(text).then(() => {
        TW.workbench.alert.create("Copied to clipboard", "notice");
    });
}
</script>

<style scoped>
table {
    border-collapse: collapse;
}

th {
    cursor: pointer;
    user-select: none;
    text-align: left;
    padding: 8px;
    background-color: var(--table-row-bg-odd);
}

th:hover {
    background-color: var(--bg-hover);
}

td {
    padding: 8px;
    border-bottom: 1px solid var(--border-color);
}

.copy-cell {
    text-align: center;
}

.count-cell {
    color: white;
    font-weight: bold;
    text-align: center;
}

.pending-text {
    color: #666;
    font-style: italic;
}

.success-text {
    color: #666;
}
</style>

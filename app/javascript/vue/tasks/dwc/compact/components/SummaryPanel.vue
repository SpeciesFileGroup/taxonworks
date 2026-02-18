<template>
    <div class="dwc-compact-summary panel content">
        <h3>Summary</h3>
        <table class="vue-table">
            <tbody>
                <tr>
                    <td>Total rows (compacted)</td>
                    <td>{{ meta.total_rows || rows.length }}</td>
                </tr>
                <tr>
                    <td>Total individualCount</td>
                    <td>{{ totalIndividualCount }}</td>
                </tr>
                <tr>
                    <td>Unique scientificName values</td>
                    <td>{{ uniqueScientificNames }}</td>
                </tr>
                <tr>
                    <td>Preview mode</td>
                    <td>{{ meta.preview ? "Yes" : "No" }}</td>
                </tr>
                <tr v-if="meta.without_catalog_number_rows > 0">
                    <td>Rows without catalogNumber (excluded)</td>
                    <td>
                        {{ meta.without_catalog_number_rows }} rows,
                        {{
                            meta.without_catalog_number_individual_count
                        }}
                        individuals
                    </td>
                </tr>
                <tr v-if="meta.pre_1700_rows > 0" class="pre-1700-warning">
                    <td>Rows with year before 1700</td>
                    <td>
                        {{ meta.pre_1700_rows }} rows,
                        {{ meta.pre_1700_individual_count }} individuals
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</template>

<script setup>
import { computed } from "vue";

const props = defineProps({
    rows: {
        type: Array,
        required: true,
    },
    allRows: {
        type: Array,
        default: () => [],
    },
    meta: {
        type: Object,
        default: () => ({}),
    },
});

const totalIndividualCount = computed(() =>
    props.rows.reduce(
        (sum, row) => sum + (parseInt(row.individualCount) || 0),
        0,
    ),
);

const uniqueScientificNames = computed(
    () => new Set(props.rows.map((r) => r.scientificName).filter(Boolean)).size,
);
</script>

<style scoped>
.dwc-compact-summary {
    margin-bottom: 1em;
}

.dwc-compact-summary table {
    max-width: 500px;
}

.dwc-compact-summary td:first-child {
    font-weight: bold;
    padding-right: 1em;
}

.pre-1700-warning td {
    background-color: #fff3e0;
    color: #e65100;
}
</style>

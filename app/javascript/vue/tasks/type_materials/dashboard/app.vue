<template>
    <div class="type-material-dashboard">
        <VSpinner
            v-if="isLoading"
            legend="Loading..."
        />

        <div
            v-if="error"
            class="type-material-error"
        >
            {{ error }}
        </div>

        <template v-if="report">
            <div class="type-material-charts">
                <ChartTaxonNameCoverage :coverage="report.taxon_name_coverage" />
                <ChartCounts
                    title="Type material by type"
                    :counts="report.type_type_counts"
                    value-name="Records"
                />
                <ChartCounts
                    title="Type material by sex"
                    :counts="report.sex_counts"
                    value-name="Records"
                />
                <ChartGeoreference :georeference="report.georeference" />
            </div>

            <div class="type-material-charts-wide">
                <ChartDecades :decades="report.decades" />
            </div>

            <div class="type-material-charts-wide">
                <ChartStacked
                    title="Individuals by repository and type"
                    :stacked="report.repository_by_type"
                />
            </div>

            <div class="type-material-charts-wide">
                <ChartStacked
                    title="Individuals by country and type"
                    :stacked="report.country_by_type"
                />
            </div>

            <TypeMaterialTable
                :type-types="report.table.type_types"
                :rows="report.table.rows"
                :truncated="report.meta.table_truncated"
            />
        </template>
    </div>
</template>

<script setup>
import { ref } from "vue";
import qs from "qs";
import { TypeMaterial } from "@/routes/endpoints";
import { LinkerStorage } from "@/shared/Filter/utils";
import VSpinner from "@/components/ui/VSpinner.vue";
import ChartTaxonNameCoverage from "./components/ChartTaxonNameCoverage.vue";
import ChartCounts from "./components/ChartCounts.vue";
import ChartGeoreference from "./components/ChartGeoreference.vue";
import ChartDecades from "./components/ChartDecades.vue";
import ChartStacked from "./components/ChartStacked.vue";
import TypeMaterialTable from "./components/TypeMaterialTable.vue";

const isLoading = ref(false);
const error = ref(null);
const report = ref(null);

function getInitialParams() {
    const urlParams = qs.parse(window.location.search, {
        ignoreQueryPrefix: true,
        arrayLimit: 2000,
    });
    const stored = LinkerStorage.getParameters();

    LinkerStorage.removeParameters();

    return { ...urlParams, ...stored };
}

async function loadReport(params) {
    isLoading.value = true;
    error.value = null;

    try {
        const response = await TypeMaterial.dashboardReport(params);
        report.value = response.body;
    } catch (e) {
        error.value = e.message || "Request failed";
    } finally {
        isLoading.value = false;
    }
}

loadReport(getInitialParams());
</script>

<style scoped>
.type-material-dashboard {
    padding: 1em;
    max-width: 100%;
}

.type-material-charts {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
    gap: 1em;
    margin: 1em 0;
}

.type-material-charts-wide {
    margin: 1em 0;
}

.type-material-error {
    margin: 1em 0;
    padding: 0.5em 1em;
    background-color: #fff3cd;
    border: 1px solid #ffc107;
    border-radius: 4px;
    color: #c62828;
}
</style>

<template>
    <EChart
        :title="title"
        :option="option"
        :note="note"
    />
</template>

<script setup>
import { computed } from "vue";
import EChart from "./EChart.vue";

const props = defineProps({
    decades: {
        type: Object,
        required: true,
    },
});

const title = "Species-group names by decade (type material coverage)";

const note = computed(
    () =>
        `Taxon names without year (n = ${props.decades.without_year || 0}) not included.`,
);

const option = computed(() => {
    const windows = props.decades.windows || [];

    return {
        tooltip: { trigger: "axis", axisPointer: { type: "shadow" } },
        legend: { data: ["With type material", "Without type material"] },
        grid: { left: "3%", right: "4%", bottom: "3%", containLabel: true },
        xAxis: {
            type: "category",
            data: windows.map((w) => `${w.decade}s`),
            axisLabel: { rotate: 45, interval: 0 },
        },
        yAxis: { type: "value", name: "Names" },
        series: [
            {
                name: "With type material",
                type: "bar",
                stack: "coverage",
                itemStyle: { color: "#4caf50" },
                data: windows.map((w) => w.with),
            },
            {
                name: "Without type material",
                type: "bar",
                stack: "coverage",
                itemStyle: { color: "#bdbdbd" },
                data: windows.map((w) => w.without),
            },
        ],
    };
});
</script>

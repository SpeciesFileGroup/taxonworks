<template>
    <EChart :title="title" :option="option" />
</template>

<script setup>
import { computed } from "vue";
import EChart from "./EChart.vue";

// Stacked bar of summed individuals, one stack series per type_type. Reused for
// the per-repository and per-country breakdowns. `stacked` is the controller's
// { categories, type_types, series: [{ type_type, data }] } payload.
const props = defineProps({
    title: {
        type: String,
        required: true,
    },
    stacked: {
        type: Object,
        required: true,
    },
    valueName: {
        type: String,
        default: "Individuals",
    },
});

const option = computed(() => {
    const { categories = [], series = [] } = props.stacked;

    return {
        tooltip: { trigger: "axis", axisPointer: { type: "shadow" } },
        legend: { type: "scroll", top: 0 },
        grid: { left: "3%", right: "4%", bottom: "3%", top: 40, containLabel: true },
        xAxis: {
            type: "category",
            data: categories,
            axisLabel: { rotate: 45, interval: 0 },
        },
        yAxis: { type: "value", name: props.valueName },
        series: series.map((s) => ({
            name: s.type_type,
            type: "bar",
            stack: "type_type",
            data: s.data,
        })),
    };
});
</script>

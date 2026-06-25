<template>
    <EChart :title="title" :option="option" />
</template>

<script setup>
import { computed } from "vue";
import EChart from "./EChart.vue";

// A simple descending bar chart from a { label: count } object. Used for both
// the type_type counts and the sex counts.
const props = defineProps({
    title: {
        type: String,
        required: true,
    },
    counts: {
        type: Object,
        required: true,
    },
    valueName: {
        type: String,
        default: "Count",
    },
});

const option = computed(() => {
    const entries = Object.entries(props.counts);

    return {
        tooltip: { trigger: "axis", axisPointer: { type: "shadow" } },
        grid: { left: "3%", right: "4%", bottom: "3%", containLabel: true },
        xAxis: {
            type: "category",
            data: entries.map(([label]) => label),
            axisLabel: { rotate: entries.length > 6 ? 45 : 0, interval: 0 },
        },
        yAxis: { type: "value", name: props.valueName },
        series: [
            {
                type: "bar",
                data: entries.map(([, count]) => count),
            },
        ],
    };
});
</script>

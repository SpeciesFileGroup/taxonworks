<template>
    <EChart :title="title" :option="option" />
</template>

<script setup>
import { computed } from "vue";
import EChart from "./EChart.vue";

const props = defineProps({
    coverage: {
        type: Object,
        required: true,
    },
});

const title = "Species-group names with / without type material";

const option = computed(() => ({
    tooltip: { trigger: "axis" },
    grid: { left: "3%", right: "4%", bottom: "3%", containLabel: true },
    xAxis: {
        type: "category",
        data: ["With type material", "Without type material"],
    },
    yAxis: { type: "value", name: "Names" },
    series: [
        {
            type: "bar",
            data: [
                {
                    value: props.coverage.with || 0,
                    itemStyle: { color: "#4caf50" },
                },
                {
                    value: props.coverage.without || 0,
                    itemStyle: { color: "#bdbdbd" },
                },
            ],
            label: { show: true, position: "top" },
        },
    ],
}));
</script>

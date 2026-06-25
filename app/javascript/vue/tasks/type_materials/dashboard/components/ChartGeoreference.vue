<template>
    <EChart :title="title" :option="option" />
</template>

<script setup>
import { computed } from "vue";
import EChart from "./EChart.vue";

// Georeferenced type-material collection objects, shown as percentages with the
// underlying counts available on mouse over.
const props = defineProps({
    georeference: {
        type: Object,
        required: true,
    },
});

const title = "Georeferenced type material (collection objects)";

const option = computed(() => {
    const { georeferenced = 0, not_georeferenced = 0, total = 0 } = props.georeference;
    const percent = (value) => (total > 0 ? (value / total) * 100 : 0);

    return {
        tooltip: {
            trigger: "axis",
            axisPointer: { type: "shadow" },
            formatter: (params) => {
                const point = params[0];
                const count = point.dataIndex === 0 ? georeferenced : not_georeferenced;
                return `${point.name}<br/>${point.value.toFixed(1)}% (${count} of ${total})`;
            },
        },
        grid: { left: "3%", right: "4%", bottom: "3%", containLabel: true },
        xAxis: {
            type: "category",
            data: ["Georeferenced", "Not georeferenced"],
        },
        yAxis: { type: "value", name: "%", max: 100 },
        series: [
            {
                type: "bar",
                data: [
                    { value: percent(georeferenced), itemStyle: { color: "#1976d2" } },
                    { value: percent(not_georeferenced), itemStyle: { color: "#bdbdbd" } },
                ],
                label: {
                    show: true,
                    position: "top",
                    formatter: (params) => `${params.value.toFixed(1)}%`,
                },
            },
        ],
    };
});
</script>

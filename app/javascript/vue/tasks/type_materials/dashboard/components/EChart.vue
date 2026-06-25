<template>
    <div class="panel content type-material-chart">
        <h3>{{ title }}</h3>
        <div ref="chartRef" class="chart-container" />
        <p
            v-if="note"
            class="type-material-chart-note"
        >
            {{ note }}
        </p>
    </div>
</template>

<script setup>
import { ref, watch, onMounted, onBeforeUnmount } from "vue";

// Generic Apache ECharts wrapper. `echarts` is loaded globally from a CDN in
// the task view. Pass a fully-formed ECharts `option` object.
const props = defineProps({
    title: {
        type: String,
        required: true,
    },
    option: {
        type: Object,
        default: null,
    },
    note: {
        type: String,
        default: "",
    },
});

const chartRef = ref(null);
let chart = null;

function render() {
    if (!chartRef.value || !window.echarts || !props.option) return;

    if (!chart) {
        chart = window.echarts.init(chartRef.value);
    }

    chart.setOption(props.option, true);
}

function resize() {
    chart?.resize();
}

onMounted(() => {
    render();
    window.addEventListener("resize", resize);
});

watch(() => props.option, render, { deep: true });

onBeforeUnmount(() => {
    window.removeEventListener("resize", resize);
    chart?.dispose();
});
</script>

<style scoped>
.type-material-chart .chart-container {
    width: 100%;
    height: 320px;
}

.type-material-chart-note {
    margin: 0.5em 0 0;
    font-size: 0.85em;
    color: #666;
}
</style>

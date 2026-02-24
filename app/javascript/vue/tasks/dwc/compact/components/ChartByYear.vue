<template>
    <div class="dwc-compact-chart panel content">
        <h3>Individuals by year</h3>
        <div ref="chartRef" class="chart-container" />
    </div>
</template>

<script setup>
import { ref, watch, onMounted, onBeforeUnmount } from "vue";

const MIN_YEAR = 1700;

const props = defineProps({
    rows: {
        type: Array,
        required: true,
    },
});

const chartRef = ref(null);
let chart = null;

function extractYear(eventDate) {
    if (!eventDate) return null;

    const dateString = eventDate.includes("/")
        ? eventDate.split("/")[0]
        : eventDate;
    const match = dateString.match(/^(\d{4})/);

    return match ? parseInt(match[1]) : null;
}

function aggregate() {
    const counts = {};

    props.rows.forEach((row) => {
        const year = extractYear(row.eventDate);
        const count = parseInt(row.individualCount) || 0;

        if (year && year >= MIN_YEAR) {
            counts[year] = (counts[year] || 0) + count;
        }
    });

    return counts;
}

function renderChart() {
    if (!chartRef.value || !window.echarts) return;

    if (!chart) {
        chart = window.echarts.init(chartRef.value);
    }

    const counts = aggregate();
    const rawYears = Object.keys(counts).map(Number);

    if (rawYears.length === 0) {
        chart.setOption({
            title: {
                text: "No data with year >= " + MIN_YEAR,
                left: "center",
                top: "middle",
            },
            xAxis: { show: false },
            yAxis: { show: false },
            series: [],
        });
        return;
    }

    const minYear = Math.min(...rawYears);
    const maxYear = Math.max(...rawYears);

    const years = [];
    const values = [];

    for (let y = minYear; y <= maxYear; y++) {
        years.push(String(y));
        values.push(counts[y] || 0);
    }

    chart.setOption({
        tooltip: { trigger: "axis" },
        xAxis: { type: "category", data: years, axisLabel: { rotate: 45 } },
        yAxis: { type: "value", name: "individualCount" },
        series: [{ type: "bar", data: values }],
    });
}

onMounted(() => {
    renderChart();
});

watch(() => props.rows, renderChart, { deep: true });

onBeforeUnmount(() => {
    chart?.dispose();
});
</script>

<style scoped>
.chart-container {
    width: 100%;
    height: 300px;
}
</style>

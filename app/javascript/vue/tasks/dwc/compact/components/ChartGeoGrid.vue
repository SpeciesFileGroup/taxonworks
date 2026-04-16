<template>
    <div class="dwc-compact-chart panel content">
        <h3>Individuals by location (0.5° grid)</h3>
        <div ref="chartRef" class="chart-container" />
    </div>
</template>

<script setup>
import { ref, watch, onMounted, onBeforeUnmount } from "vue";
import qs from "qs";

const FILTER_URL = "/tasks/collection_objects/filter";

const props = defineProps({
    rows: {
        type: Array,
        required: true,
    },
    filterParams: {
        type: Object,
        default: null,
    },
});

const chartRef = ref(null);
let chart = null;

const BIN_SIZE = 0.5;

function binCoord(value) {
    return Math.floor(value / BIN_SIZE) * BIN_SIZE;
}

function aggregate() {
    const counts = {};

    props.rows.forEach((row) => {
        const lat = parseFloat(row.decimalLatitude);
        const lon = parseFloat(row.decimalLongitude);
        const count = parseInt(row.individualCount) || 0;

        if (isNaN(lat) || isNaN(lon) || count === 0) return;

        const binLat = binCoord(lat);
        const binLon = binCoord(lon);
        const key = `${binLon},${binLat}`;

        counts[key] = (counts[key] || 0) + count;
    });

    return counts;
}

// Build a closed WKT POLYGON for a 0.5° bin given its SW corner.
function binToWkt(lon, lat) {
    const lonMax = +(lon + BIN_SIZE).toFixed(6);
    const latMax = +(lat + BIN_SIZE).toFixed(6);
    const lonMin = +lon.toFixed(6);
    const latMin = +lat.toFixed(6);
    return `POLYGON ((${lonMin} ${latMin}, ${lonMax} ${latMin}, ${lonMax} ${latMax}, ${lonMin} ${latMax}, ${lonMin} ${latMin}))`;
}

function openFilterForBin(lon, lat) {
    const wkt = binToWkt(lon, lat);
    const base = props.filterParams || {};

    // filterParams may arrive with params nested under collection_object_query (linker style)
    // or flat (direct filter style). Flatten to match what the CO filter task expects.
    const { collection_object_query: coQuery, collecting_event_query: ceQuery, ...rest } = base;
    const flatBase = coQuery ? { ...rest, ...coQuery } : { ...rest };

    const combined = {
        ...flatBase,
        collecting_event_query: {
            ...(ceQuery || {}),
            wkt,
        },
    };

    const queryString = qs.stringify(combined, {
        arrayFormat: "brackets",
        encode: false,
    });
    window.open(`${FILTER_URL}?${queryString}`, "_blank");
}

function renderChart() {
    if (!chartRef.value || !window.echarts) return;

    if (!chart) {
        chart = window.echarts.init(chartRef.value);
        chart.on("click", { seriesIndex: 0 }, (params) => {
            // With category axes params.value is [lonLabel, latLabel, count]
            const lon = parseFloat(params.value[0]);
            const lat = parseFloat(params.value[1]);
            openFilterForBin(lon, lat);
        });
    }

    const counts = aggregate();

    if (Object.keys(counts).length === 0) {
        chart.setOption({
            title: {
                text: "No georeferenced data",
                left: "center",
                top: "middle",
            },
            series: [],
        });
        return;
    }

    // Build sorted category arrays covering every bin in the range (dense grid).
    const rawPoints = Object.entries(counts).map(([key, count]) => {
        const [lon, lat] = key.split(",").map(Number);
        return { lon, lat, count };
    });

    const minLon = Math.min(...rawPoints.map((p) => p.lon));
    const maxLon = Math.max(...rawPoints.map((p) => p.lon));
    const minLat = Math.min(...rawPoints.map((p) => p.lat));
    const maxLat = Math.max(...rawPoints.map((p) => p.lat));

    // Generate the full range of bin labels so the grid is evenly spaced
    // even when some cells have no data (sparse datasets).
    const lonCategories = [];
    for (let v = minLon; v <= maxLon + 1e-9; v = +(v + BIN_SIZE).toFixed(6)) {
        lonCategories.push(String(v));
    }
    const latCategories = [];
    for (let v = minLat; v <= maxLat + 1e-9; v = +(v + BIN_SIZE).toFixed(6)) {
        latCategories.push(String(v));
    }

    const maxCount = Math.max(...rawPoints.map((p) => p.count));

    // Data for bar3D: [lonLabel, latLabel, count]
    const barData = rawPoints.map(({ lon, lat, count }) => [
        String(lon),
        String(lat),
        count,
    ]);

    // Cardinal extreme bars (furthest N/S/E/W)
    const northBar = rawPoints.reduce((a, b) => (b.lat > a.lat ? b : a));
    const southBar = rawPoints.reduce((a, b) => (b.lat < a.lat ? b : a));
    const eastBar  = rawPoints.reduce((a, b) => (b.lon > a.lon ? b : a));
    const westBar  = rawPoints.reduce((a, b) => (b.lon < a.lon ? b : a));

    const cardinalSet = new Map();
    for (const p of [northBar, southBar, eastBar, westBar]) {
        cardinalSet.set(`${p.lon},${p.lat}`, p);
    }

    // Sphere series uses the same category labels; z at half-bar height
    const sphereData = Array.from(cardinalSet.values()).map(({ lon, lat, count }) => [
        String(lon),
        String(lat),
        count / 2,
    ]);

    const tooltipFormatter = (params) => {
        const lon = parseFloat(params.value[0]);
        const lat = parseFloat(params.value[1]);
        const count = params.value[2];
        return `Lon ${lon}–${+(lon + BIN_SIZE).toFixed(6)}, Lat ${lat}–${+(lat + BIN_SIZE).toFixed(6)}<br/>individualCount: ${count}`;
    };

    // Scale box to the aspect ratio of the data so cells appear square-ish.
    const numLon = lonCategories.length;
    const numLat = latCategories.length;
    const BASE = 200;
    const aspect = numLon / numLat;
    const BOX_WIDTH = aspect >= 1 ? BASE : Math.round(BASE * aspect);
    const BOX_DEPTH = aspect <= 1 ? BASE : Math.round(BASE / aspect);

    chart.setOption({
        tooltip: { formatter: tooltipFormatter },
        visualMap: {
            show: true,
            min: 0,
            max: maxCount,
            seriesIndex: 0,
            inRange: {
                color: [
                    "#313695",
                    "#4575b4",
                    "#74add1",
                    "#abd9e9",
                    "#fdae61",
                    "#f46d43",
                    "#d73027",
                    "#a50026",
                ],
            },
        },
        xAxis3D: {
            name: "Longitude",
            type: "category",
            data: lonCategories,
        },
        yAxis3D: {
            name: "Latitude",
            type: "category",
            data: latCategories,
        },
        zAxis3D: {
            name: "Individuals",
            type: "value",
            min: 0,
        },
        grid3D: {
            boxWidth: BOX_WIDTH,
            boxDepth: BOX_DEPTH,
            boxHeight: 80,
            viewControl: {
                projection: "perspective",
                autoRotate: false,
            },
        },
        series: [
            {
                type: "bar3D",
                data: barData,
                shading: "lambert",
                label: { show: false },
                itemStyle: { opacity: 0.85 },
                emphasis: {
                    itemStyle: { opacity: 1, color: "#ffe082" },
                },
            },
            {
                type: "scatter3D",
                data: sphereData,
                symbol: "circle",
                symbolSize: 20,
                itemStyle: {
                    color: "rgba(255, 255, 255, 0.35)",
                    borderColor: "rgba(255, 255, 255, 0.8)",
                    borderWidth: 1,
                },
                label: { show: false },
                tooltip: { show: false },
            },
        ],
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
    height: 500px;
}
</style>

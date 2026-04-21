<template>
    <div class="dwc-compact-chart panel content">
        <h3>Individuals by species and month</h3>
        <div ref="chartRef" class="chart-container" />
    </div>
</template>

<script setup>
import { ref, watch, onMounted, onBeforeUnmount } from 'vue'

const props = defineProps({
    rows: {
        type: Array,
        required: true,
    },
})

const chartRef = ref(null)
let chart = null

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

function extractMonth(eventDate) {
    if (!eventDate) return null
    const datePart = eventDate.includes('/') ? eventDate.split('/')[0] : eventDate
    const match = datePart.match(/^\d{4}-(\d{2})/)
    return match ? parseInt(match[1]) - 1 : null  // 0-indexed
}

// Returns { species -> [month0count, month1count, ..., month11count] }
function aggregate() {
    const map = {}

    props.rows.forEach((row) => {
        const name = row.scientificName
        if (!name) return

        const month = extractMonth(row.eventDate)
        if (month === null) return

        const count = parseInt(row.individualCount) || 0
        if (!map[name]) map[name] = new Array(12).fill(0)
        map[name][month] += count
    })

    return map
}

// Sort species: descending by Jan count, breaking ties with Feb, Mar, etc.
function sortSpecies(map) {
    return Object.keys(map).sort((a, b) => {
        for (let m = 0; m < 12; m++) {
            const diff = map[b][m] - map[a][m]
            if (diff !== 0) return diff
        }
        return a.localeCompare(b)
    })
}

function renderChart() {
    if (!chartRef.value || !window.echarts) return

    if (!chart) {
        chart = window.echarts.init(chartRef.value)
    }

    const map = aggregate()
    const species = sortSpecies(map)

    if (species.length === 0) {
        chart.setOption({
            title: { text: 'No data with scientificName and eventDate', left: 'center', top: 'middle' },
            series: [],
        })
        return
    }

    // Collect all counts to scale bubble sizes
    const allCounts = species.flatMap((s) => map[s])
    const maxCount = Math.max(...allCounts.filter(Boolean), 1)

    // Build scatter data: [monthIndex, speciesIndex, count]
    const data = []
    species.forEach((s, si) => {
        map[s].forEach((count, mi) => {
            if (count > 0) data.push([mi, si, count])
        })
    })

    const containerHeight = Math.max(300, species.length * 22 + 80)
    chartRef.value.style.height = containerHeight + 'px'
    chart.resize()

    const maxLabelLength = Math.max(...species.map((s) => s.length), 10)
    const leftMargin = Math.min(Math.max(maxLabelLength * 7, 150), 400)

    chart.setOption({
        tooltip: {
            formatter(params) {
                const [mi, si, count] = params.value
                return `${species[si]}<br/>${MONTHS[mi]}: ${count} individuals`
            },
        },
        grid: { left: leftMargin, right: 20, top: 10, bottom: 40 },
        xAxis: {
            type: 'category',
            data: MONTHS,
            boundaryGap: true,
            axisLabel: { interval: 0 },
        },
        yAxis: {
            type: 'category',
            data: species,
            axisLabel: {
                fontSize: 11,
                overflow: 'truncate',
                width: leftMargin - 20,
            },
        },
        series: [
            {
                type: 'scatter',
                data,
                symbolSize(val) {
                    const count = val[2]
                    // Scale: min 4px, max 40px
                    return Math.max(4, Math.round(Math.sqrt(count / maxCount) * 40))
                },
                itemStyle: { color: '#4575b4', opacity: 0.75 },
                tooltip: { show: true },
            },
        ],
    })
}

onMounted(() => {
    renderChart()
})

watch(() => props.rows, renderChart, { deep: true })

onBeforeUnmount(() => {
    chart?.dispose()
})
</script>

<style scoped>
.chart-container {
    width: 100%;
    min-height: 300px;
}
</style>

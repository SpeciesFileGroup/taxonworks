<script>
import { h, ref, watch, defineComponent, onMounted, onBeforeUnmount } from 'vue'
import {
  Chart,
  CategoryScale,
  LineElement,
  BarElement,
  BarController,
  LinearScale,
  Legend,
  Title,
  Tooltip
} from 'chart.js'

Chart.register(
  CategoryScale,
  LineElement,
  BarElement,
  BarController,
  LinearScale,
  Legend,
  Title,
  Tooltip
)

export default defineComponent({
  name: 'VueChart',
  props: {
    type: {
      type: String,
      required: true
    },

    data: {
      type: Object,
      required: true
    },

    options: {
      type: Object,
      default: () => ({})
    },

    plugins: {
      type: Array,
      default: () => []
    }
  },

  setup (props) {
    const chartRef = ref(null)
    let chartObject

    const initChart = () => {
      chartObject = new Chart(chartRef.value.getContext('2d'), {
        type: props.type,
        data: props.data,
        options: props.options,
        plugins: props.plugins
      })
    }

    const update = () => {
      if (chartObject) {
        chartObject.data = props.data
        chartObject.options = props.options
        chartObject.update()
      }
    }

    const destroy = () => {
      if (chartObject) {
        chartObject.destroy()
        chartObject = null
      }
    }

    onMounted(() => {
      initChart()
    })

    onBeforeUnmount(() => {
      destroy()
    })

    watch([
      () => props.data
    ], () => {
      update()
    })

    return {
      chartRef,
      chartObject,
      destroy,
      update
    }
  },

  render () {
    return h('canvas', {
      ref: 'chartRef'
    })
  }
})
</script>

<template>
  <div
    v-if="!datasetReady"
    class="full_width panel"
    style="height: 50vh">
    <spinner-component
      :logo-size="{
        width: '100px',
        height: '100px'
      }"
      :legend="`<h3>${disableStatus[dataset.status]}</h3> <span>Refresh in ${remain} seconds...</span>`"/>
  </div>
</template>

<script>
import SpinnerComponent from 'components/spinner'
import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'
import { disableStatus } from '../const/datasetStatus.js'

export default {
  components: {
    SpinnerComponent
  },
  computed: {
    dataset () {
      return this.$store.getters[GetterNames.GetDataset]
    },
    datasetReady () {
      return !Object.keys(this.disableStatus).includes(this.dataset.status)
    }
  },
  data () {
    return {
      reloadTime: 10,
      countdownProcess: undefined,
      remain: this.reloadTime,
      disableStatus: disableStatus
    }
  },
  mounted () {
    if (!this.datasetReady) {
      this.loadDataset()
    }
  },
  methods: {
    loadDataset () {
      this.$store.dispatch(ActionNames.LoadDataset, this.dataset.id).then(response => {
        if (!this.datasetReady) {
          this.countdown(this.reloadTime)
        } else {
          this.$store.dispatch(ActionNames.LoadDatasetRecords)
        }
      })
    },
    countdown (seconds) {
      this.remain = seconds
      if (seconds === 0) {
        this.loadDataset()
      } else {
        this.countdownProcess = setTimeout(() => {
          this.countdown(seconds - 1)
        }, 1000)
      }
    }
  },
  destroyed () {
    clearTimeout(this.countdownProcess)
  }
}
</script>

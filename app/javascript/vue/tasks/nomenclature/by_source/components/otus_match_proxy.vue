<template>
  <div>
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <div class="flex-separate middle">
      <h2>OTU summary</h2>
      <span
        class="cursor-pointer"
        @click="otu_name_list = []"
        data-icon="reset">
        Reset
      </span>
    </div>
    <otu-table-component :list="otu_name_list"/>
  </div>
</template>
<script>

import OtuTableComponent from './tables/otu_table.vue'
import Spinner from 'components/spinner.vue'
import { Otu } from 'routes/endpoints'

export default {
  components: {
    OtuTableComponent,
    Spinner
  },

  props: {
    sourceID: {
      type: String,
      default: '0',
    },
    updateOtus: {
      type: Boolean,
      default: false
    },
    summarize: {
      type: Object,
      default: undefined
    }
  },

  data () {
    return {
      otu_name_list: [],
      otu_id_list: [],
      processingList: false,
      isLoading: false,
      lastRun: undefined
    }
  },

  watch: {
    summarize: { 
      handler(newVal) {
        this.getSourceOtus(newVal.type, newVal.list)
      },
      deep: true
    }
  },

  methods: {
    getSourceOtus(type, list) {
      const promises = []
      const runTime = Date.now()
      this.lastRun = runTime
      this.isLoading = true

      promises.push(this.processType(this.getIdsList(list), type))

      Promise.all(promises).then(lists => {
        if (this.lastRun == runTime) {
          if (this.append) {
            let concat = this.otu_id_list.concat(lists)

            concat = concat.filter((item, index, self) =>
              index === self.findIndex((i) => (
                i.id === item.id
              ))
            )
            this.otu_id_list = concat
          }

          this.otu_id_list = [].concat.apply([], lists)
          this.isLoading = false
        }
      })
    },
    addOtu(otu) {
      if((this.otu_name_list.findIndex(item => item.id === otu.id)) < 0) {
        this.otu_name_list.push(otu)
      }
    },

    getIdsList(list) {
      return list.map((item) => item.citation_object_id)
    },

    processType (list, type) {
      if (!list.length) return
      return new Promise((resolve, reject) => {
        const promises = []
        const chunkArray = []
        const maxSize = 50
        let i, j

        for (i = 0, j = list.length; i < j; i += maxSize) {
          if (list.length > i+maxSize) {
            chunkArray.push(list.slice(i, i + maxSize))
          }
          else {
            chunkArray.push(list.slice(i, list.length))
          }
        }
        chunkArray.forEach(item => {
          promises.push(Otu.where({ [type]: item }).then(response => {
            response.body.forEach(this.addOtu)
          }))
        })

        Promise.all(promises).then(response => {
          resolve()
        })
      })
    },

    getDWCATable (list) {
      const IDS = list.map(item => item.id)
      const chunk = IDS.length / this.perRequest
      const chunkArray = []
      let i, j

      for (i = 0,j = IDS.length; i < j; i += chunk) {
        chunkArray.push(IDS.slice(i, i + chunk))
      }
      this.getDWCA(chunkArray)
    }
  }
}
</script>

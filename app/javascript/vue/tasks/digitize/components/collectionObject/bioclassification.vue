<template>
  <div>
    <h2>Biocuration</h2>
    <div>
      <label>Total</label>
      <br>
      <input
        class="total-input"
        type="number"
        v-model="total">
      <div v-for="group in biocurationsGroups">
        <label>{{ group.name }}</label>
        <br>
        <template
          v-for="item in group.list">
          <button
            type="button"
            class="bottom button-submit normal-input biocuration-toggle-button"
            @click="addToQueue(item.id)"
            v-if="(biologicalId ? !checkExist(item.id) : !checkInQueue(item.id))">{{ item.name }}
          </button>
          <button
            type="button"
            class="bottom button-delete normal-input biocuration-toggle-button"
            @click="(biologicalId ? removeEntry(item) : removeFromQueue(item.id))"
            v-else>{{ item.name }}
          </button>
        </template>
      </div>
    </div>
  </div>
</template>

<script>
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import { 
  GetBiocurationsTypes, 
  GetBiocurationsCreated, 
  CreateBiocurationClassification,
  GetBiocurationsGroupTypes,
  DestroyBiocuration,
  GetBiocurationsTags } from '../../request/resources.js'

export default {
  computed: {
    collectionObject() {
      return this.$store.getters[GetterNames.GetCollectionObject]
    },
    biologicalId() {
      return this.$store.getters[GetterNames.GetCollectionObject].id
    },
    total: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionObject].total
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionObjectTotal, value)
      }
    },
  },
  data() {
    return {
      biocutarionsType: [],
      biocurationsGroups: [],
      addQueue: [],
      createdBiocutarions: [],
      delay: undefined
    }
  },
  mounted: function () {
    GetBiocurationsGroupTypes().then(response => {
      this.biocurationsGroups = response
      GetBiocurationsTypes().then(response => {
        this.biocutarionsType = response
        this.splitGroups()
      })
    })
  },
  watch: {
    biologicalId: {
      handler (newVal, oldVal) {
        this.createdBiocutarions = []
        if (newVal && oldVal == undefined) {
          this.processQueue()
        }
        if (newVal != undefined && newVal != oldVal) {
          this.addQueue = []
          if(this.delay) clearTimeout(this.delay)
          this.delay = setTimeout(() => {
            GetBiocurationsCreated(newVal).then(response => {
              this.createdBiocutarions = response
            })
          }, 250)
        }
      },
      immediate: true
    },
    addQueue: {
      handler () {
        if (this.biologicalId && this.addQueue.length) {
          this.processQueue()
        }
      }
    }
  },
  methods: {
    splitGroups() {
      let that = this
      this.biocurationsGroups
      this.biocurationsGroups.forEach((item, index) => {
        GetBiocurationsTags(item.id).then(response =>{
          let tmpArray = []
          response.forEach(item => {
            that.biocutarionsType.forEach(itemClass => {
              if(itemClass.id == item.tag_object_id) {
                tmpArray.push(itemClass)
                return
              }
            })
          })
          that.$set(that.biocurationsGroups[index], 'list', tmpArray)
        })         
      })
    },
    addToQueue (biocuration) {
      this.addQueue.push(biocuration)
    },
    processQueue () {
      this.addQueue.forEach((id) => {
        CreateBiocurationClassification(this.createBiocurationObject(id)).then(response => {
          this.createdBiocutarions.push(response)
          this.$store.commit(MutationNames.AddBiocuration, response)
        })
        this.addQueue = []
      })
    },
    checkExist (id) {
      let found = this.createdBiocutarions.find((bio) => {
        return id == bio.biocuration_class_id
      })
      return (found != undefined)
    },
    checkInQueue (id) {
      let found = this.addQueue.find((biocurationId) => {
        return id == biocurationId
      })
      return (found != undefined)
    },
    getCreatedBiocurations () {
      this.biocutarionsType.forEach((biocuration) => {
        GetBiocuration().then((response) => {
          response.forEach((item) => {
            this.createdBiocutarions.push(item)
            this.$store.commit(MutationNames.AddBiocuration, response)
          })
        })
      })
    },
    removeFromQueue (id) {
      this.addQueue.splice(this.addQueue.findIndex((itemId) => { return itemId == id }), 1)
    },
    removeEntry (biocurationClass) {
      let index = this.createdBiocutarions.findIndex((item) => {
        return (item.biocuration_class_id == biocurationClass.id)
      })

      DestroyBiocuration(this.createdBiocutarions[index].id).then(response => {
        this.$store.commit(MutationNames.RemoveBiocuration, this.createdBiocutarions[index].id)
        this.createdBiocutarions.splice(index, 1)
      })
    },
    createBiocurationObject (id) {
      return {
        biocuration_classification: {
          biocuration_class_id: id,
          biological_collection_object_id: this.biologicalId
        }
      }
    }
  }
}
</script>

<style scoped>
  .total-input {
    width: 50px;
  }
  .biocuration-toggle-button {
    min-width: 60px;
    border: 0px;
    margin-right: 6px;
    margin-bottom: 6px;
    border-top-left-radius: 14px;
    border-bottom-left-radius: 14px;
  }
</style>

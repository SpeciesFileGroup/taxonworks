<template>
  <div>
    <div>
      <div v-for="group in biocurationsGroups">
        <label>{{ group.name }}</label>
        <br>
        <template
          v-for="item in group.list">
          <button
            type="button"
            class="bottom button-submit normal-input biocuration-toggle-button"
            @click="addToQueue(item.id)"
            v-if="(biologicalId ? !isCreated(item.id) : !isInQueue(item.id))">{{ item.name }}
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
import { BiocurationClassification } from 'routes/endpoints'

export default {
  props: {
    biologicalId: {
      type: [String, Number]
    },

    biocutarionsType: {
      type: Array,
      default: () => []
    },

    biocurationsGroups: {
      type: Array,
      default: () => []
    }
  },

  computed: {
    locked: {
      get () {
        return this.$store.getters[GetterNames.GetLocked]
      },
      set (value) {
        this.$store.commit([MutationNames.SetLocked, value])
      }
    }
  },

  data () {
    return {
      addQueue: [],
      createdBiocutarions: [],
      delay: 500,
      tags: []
    }
  },

  watch: {
    biologicalId: {
      handler (newVal, oldVal) {
        if ((this.locked.biocuration) && newVal == undefined) {
          this.addQueue = this.addQueue.concat(this.getCreatedBiocurationIds())
        }
        this.createdBiocutarions = []
        if (newVal && oldVal == undefined) {
          this.processQueue()
        }
        if (newVal != undefined && newVal != oldVal) {
          this.addQueue = []

          setTimeout(() => {
            BiocurationClassification.where({ biological_collection_object_id: newVal }).then(response => {
              this.createdBiocutarions = response.body
              this.$forceUpdate()
            })
          }, this.delay)
        }
      },
      immediate: true
    },

    addQueue: {
      handler () {
        if (this.biologicalId && this.addQueue.length) {
          this.processQueue()
        }
      },
      deep: true
    }
  },

  methods: {
    getCreatedBiocurationIds () {
      return this.createdBiocutarions.map(item => item.biocuration_class_id)
    },

    addToQueue (biocuration) {
      this.addQueue.push(biocuration)
    },

    processQueue () {
      this.addQueue.forEach((id) => {
        BiocurationClassification.create(this.createBiocurationObject(id)).then(response => {
          this.createdBiocutarions.push(response.body)
        })
        this.addQueue = []
      })
    },

    isCreated (id) {
      return !!this.createdBiocutarions.find(bio => id === bio.biocuration_class_id)
    },

    isInQueue (id) {
      return !!this.addQueue.find(biocurationId => id === biocurationId)
    },

    removeFromQueue (id) {
      this.addQueue.splice(this.addQueue.findIndex(itemId => itemId === id), 1)
    },

    removeEntry (biocurationClass) {
      const index = this.createdBiocutarions.findIndex(item => item.biocuration_class_id === biocurationClass.id)

      BiocurationClassification.destroy(this.createdBiocutarions[index].id).then(() => {
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

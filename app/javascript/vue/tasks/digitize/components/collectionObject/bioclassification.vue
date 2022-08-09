<template>
  <div>
    <div>
      <div v-for="group in biocurationsGroups">
        <label>{{ group.name }}</label>
        <br>
        <template
          v-for="item in group.list">
          <button
            v-if="(biologicalId ? !isCreated(item.id) : !isInQueue(item.id))"
            type="button"
            class="bottom normal-input button-submit biocuration-toggle-button"
            :class="{ 'biocuration-toggle-button__disabled': disabled }"
            :disabled="disabled"
            @click="addToQueue(item.id)"
          >
            {{ item.name }}
          </button>
          <button
            v-else
            type="button"
            class="bottom normal-input button-delete biocuration-toggle-button"
            :class="{ 'biocuration-toggle-button__disabled': disabled }"
            :disabled="disabled"
            @click="(biologicalId ? removeEntry(item) : removeFromQueue(item.id))"
          >
            {{ item.name }}
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
    },

    disabled: {
      type: Boolean,
      default: false
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

<style lang="scss" scoped>
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

    &__disabled {
      opacity: 0.3;
    }
  }

</style>

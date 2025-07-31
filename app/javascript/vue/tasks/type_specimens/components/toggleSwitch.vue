<template>
  <div>
    <fieldset>
      <legend>Biocurations</legend>
      <template
        v-for="item in biocutarionsType"
        :key="item.id"
      >
        <template v-if="biologicalId">
          <button
            type="button"
            class="bottom button-submit normal-input biocuration-toggle-button"
            @click="addToQueue(item.id)"
            v-if="!checkExist(item.id)"
          >
            {{ item.name }}
          </button>
          <button
            type="button"
            class="bottom button-delete normal-input biocuration-toggle-button"
            @click="removeEntry(item)"
            v-else
          >
            {{ item.name }}
          </button>
        </template>

        <template v-else>
          <button
            type="button"
            class="bottom button-submit normal-input biocuration-toggle-button"
            @click="addToQueue(item.id)"
            v-if="!checkInQueue(item.id)"
          >
            {{ item.name }}
          </button>
          <button
            type="button"
            class="bottom button-delete normal-input biocuration-toggle-button"
            @click="removeFromQueue(item.id)"
            v-else
          >
            {{ item.name }}
          </button>
        </template>
      </template>
      <a
        v-if="!biocutarionsType.length"
        :href="getBiocurationTaskRoute()"
        >Manage biocuration classes</a
      >
    </fieldset>
  </div>
</template>

<script>
import { RouteNames } from '@/routes/routes'
import { COLLECTION_OBJECT } from '@/constants'
import {
  BiocurationClassification,
  ControlledVocabularyTerm
} from '@/routes/endpoints'

export default {
  props: {
    biologicalId: {
      type: [String, Number],
      default: undefined
    }
  },

  data() {
    return {
      biocutarionsType: [],
      addQueue: [],
      createdBiocutarions: []
    }
  },

  created() {
    ControlledVocabularyTerm.where({ type: ['BiocurationClass'] }).then(
      (response) => {
        this.biocutarionsType = response.body
      }
    )
  },

  watch: {
    biologicalId: {
      handler(newVal, oldVal) {
        this.createdBiocutarions = []
        if (newVal && oldVal == undefined) {
          this.processQueue()
        }
        if (newVal != undefined && newVal != oldVal) {
          this.addQueue = []
          BiocurationClassification.where({
            biocuration_classification_object_id: newVal,
            biocuration_classification_object_type: COLLECTION_OBJECT
          }).then((response) => {
            this.createdBiocutarions = response.body
          })
        }
      },
      immediate: true
    },

    addQueue: {
      handler() {
        if (this.biologicalId && this.addQueue.length) {
          this.processQueue()
        }
      },
      deep: true
    }
  },

  methods: {
    getBiocurationTaskRoute() {
      return RouteNames.ManageBiocurationTask
    },

    addToQueue(biocuration) {
      this.addQueue.push(biocuration)
    },

    processQueue() {
      this.addQueue.forEach((id) => {
        BiocurationClassification.create(this.createBiocurationObject(id)).then(
          (response) => {
            this.createdBiocutarions.push(response.body)
          }
        )
        this.addQueue = []
      })
    },

    checkExist(id) {
      return !!this.createdBiocutarions.find(
        (bio) => id === bio.biocuration_class_id
      )
    },

    checkInQueue(id) {
      return !!this.addQueue.find((biocurationId) => id === biocurationId)
    },

    removeFromQueue(id) {
      this.addQueue.splice(
        this.addQueue.findIndex((itemId) => itemId === id),
        1
      )
    },

    removeEntry(biocurationClass) {
      const index = this.createdBiocutarions.findIndex(
        (item) => item.biocuration_class_id === biocurationClass.id
      )

      BiocurationClassification.destroy(
        this.createdBiocutarions[index].id
      ).then((_) => {
        this.createdBiocutarions.splice(index, 1)
      })
    },

    createBiocurationObject(id) {
      return {
        biocuration_classification: {
          biocuration_class_id: id,
          biocuration_classification_object_id: this.biologicalId,
          biocuration_classification_object_type: COLLECTION_OBJECT
        }
      }
    }
  }
}
</script>

<style>
.biocuration-toggle-button {
  min-width: 60px;
  border: 0px;
  margin-right: 6px;
  margin-bottom: 6px;
  border-top-left-radius: 14px;
  border-bottom-left-radius: 14px;
}
</style>

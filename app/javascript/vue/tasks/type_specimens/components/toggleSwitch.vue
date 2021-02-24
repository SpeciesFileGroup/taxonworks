<template>
  <div>
    <fieldset>
      <legend>Biocurations</legend>
      <template
        v-if="biologicalId"
        v-for="item in biocutarionsType">
        <button
          type="button"
          class="bottom button-submit normal-input biocuration-toggle-button"
          :key="item.id"
          @click="addToQueue(item.id)"
          v-if="!checkExist(item.id)">{{ item.name }}
        </button>
        <button
          type="button"
          :key="item.id"
          class="bottom button-delete normal-input biocuration-toggle-button"
          @click="removeEntry(item)"
          v-else>{{ item.name }}
        </button>
      </template>

      <template
        v-if="!biologicalId"
        v-for="item in biocutarionsType">
        <button
          type="button"
          :key="item.id"
          class="bottom button-submit normal-input biocuration-toggle-button"
          @click="addToQueue(item.id)"
          v-if="!checkInQueue(item.id)">{{ item.name }}
        </button>
        <button
          type="button"
          :key="item.id"
          class="bottom button-delete normal-input biocuration-toggle-button"
          @click="removeFromQueue(item.id)"
          v-else>{{ item.name }}
        </button>
      </template>
      <a
        v-if="!biocutarionsType.length"
        :href="getBiocurationTaskRoute()">Manage biocuration classes</a>
    </fieldset>
  </div>
</template>

<script>

import {
  CreateBiocurationClassification,
  GetBiocuration,
  GetBiocurationsTypes,
  GetBiocurationsCreated,
  DestroyBiocuration } from '../request/resources'
  import { RouteNames } from 'routes/routes'

export default {
  props: {
    biologicalId: {
      default: undefined
    }
  },
  data: function () {
    return {
      biocutarionsType: [],
      addQueue: [],
      createdBiocutarions: []
    }
  },
  mounted: function () {
    GetBiocurationsTypes().then(response => {
      this.biocutarionsType = response.body
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
          GetBiocurationsCreated(newVal).then(response => {
            this.createdBiocutarions = response.body
          })
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
    getBiocurationTaskRoute() {
      return RouteNames.ManageBiocurationTask
    },
    addToQueue (biocuration) {
      this.addQueue.push(biocuration)
    },
    processQueue () {
      this.addQueue.forEach((id) => {
        CreateBiocurationClassification(this.createBiocurationObject(id)).then(response => {
          this.createdBiocutarions.push(response.body)
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
          response.body.forEach((item) => {
            this.createdBiocutarions.push(item)
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

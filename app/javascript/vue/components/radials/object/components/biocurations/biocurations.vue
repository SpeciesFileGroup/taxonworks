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
            @click="createBiocuration(item.id)"
            v-if="!checkExist(item.id)">{{ item.name }}
          </button>
          <button
            type="button"
            class="bottom button-delete normal-input biocuration-toggle-button"
            @click="removeEntry(item)"
            v-else>{{ item.name }}
          </button>
        </template>
      </div>
    </div>
  </div>
</template>

<script>

import CRUD from '../../request/crud.js'
import AnnotatorExtend from '../annotatorExtend.js'

export default {
  mixins: [CRUD, AnnotatorExtend],
  data() {
    return {
      biocutarionsType: [],
      biocurationsGroups: [],
    }
  },
  mounted () {
    this.getList(`/controlled_vocabulary_terms.json?type[]=BiocurationGroup`).then(response => {
      this.biocurationsGroups = response.body
      this.getList(`/controlled_vocabulary_terms.json?type[]=BiocurationClass`).then(response => {
        this.biocutarionsType = response.body
        this.splitGroups()
      })
    })
  },
  methods: {
    createBiocuration (id) {
      this.create('/biocuration_classifications.json', this.createBiocurationObject(id)).then(response => {
        this.list.push(response.body)
      })
    },
    checkExist (id) {
      let found = this.list.find((bio) => {
        return id == bio.biocuration_class_id
      })
      return found
    },
    removeEntry (item) {
      this.removeItem(this.list.find(bio => { return item.id == bio.biocuration_class_id }))
    },
    createBiocurationObject (id) {
      return {
        biocuration_classification: {
          biocuration_class_id: id,
          biological_collection_object_id: this.metadata.object_id
        }
      }
    },
    splitGroups() {
      this.biocurationsGroups.forEach((item, index) => {
        this.getList(`/tags.json?keyword_id=${item.id}`).then(response => {
          const tmpArray = []

          response.body.forEach(item => {
            this.biocutarionsType.forEach(itemClass => {
              if(itemClass.id === item.tag_object_id) {
                tmpArray.push(itemClass)
                return
              }
            })
          })
          this.biocurationsGroups[index]['list'] = tmpArray
        })
      })
    }
  }
}
</script>

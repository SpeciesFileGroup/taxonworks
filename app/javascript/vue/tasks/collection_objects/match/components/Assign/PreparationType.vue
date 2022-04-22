<template>
  <div class="panel content">
    <spinner-component
      v-if="isSaving"
      legend="Saving..."
    />
    <h2>Preparation type</h2>
    <div class="horizontal-left-content">
      <ul
        v-for="(itemsGroup, index) in chunkList"
        :key="index"
        class="no_bullets preparation-list"
      >
        <li
          v-for="type in itemsGroup"
          :key="type.id"
          class="margin-large-right"
        >
          <label>
            <input
              type="radio"
              :value="type.id"
              name="collection-object-type"
              @click="setPreparationType(type.id)"
            >
            {{ type.name }}
          </label>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>

import SpinnerComponent from 'components/spinner'
import { CollectionObject, PreparationType } from 'routes/endpoints'
import { chunkArray } from 'helpers/arrays'

export default {
  components: {
    SpinnerComponent
  },

  props: {
    ids: {
      type: Array,
      required: true
    }
  },

  data () {
    return {
      maxPerCall: 5,
      isSaving: false,
      preparationList: []
    }
  },

  computed: {
    chunkList () {
      return chunkArray(this.preparationList, Math.ceil(this.preparationList.length / 3))
    }
  },

  created () {
    PreparationType.all().then(({ body }) => {
      this.preparationList = [
        ...body,
        {
          id: null,
          name: 'None'
        }
      ]
    })
  },

  methods: {
    setPreparationType (preparationId, arrayIds = this.ids.slice()) {
      const ids = arrayIds.splice(0, this.maxPerCall)
      const requests = ids.map(id => CollectionObject.update(id, {
        collection_object: {
          preparation_type_id: preparationId
        }
      }))

      Promise.allSettled(requests).then(() => {
        if (arrayIds.length) {
          this.setPreparationType(preparationId, arrayIds)
        } else {
          this.isSaving = false
          TW.workbench.alert.create('Preparation type was successfully set.', 'notice')
        }
      })
    }
  }
}
</script>

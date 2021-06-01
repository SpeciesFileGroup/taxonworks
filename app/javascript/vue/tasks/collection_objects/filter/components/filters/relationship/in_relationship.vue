<template>
  <div>
    <h3>In relationship</h3>
    <div class="separate-bottom">
      <ul
        v-if="biologicalRelationships.length"
        class="no_bullets">
        <li
          v-for="(item) in biologicalRelationships"
          :key="item.id">
          <label>
            <input
              :value="item.id"
              v-model="inRelationships"
              type="checkbox">
            {{ item.inverted_name ? `${item.name} / ${item.inverted_name}` : item.name }}
          </label>
        </li>
      </ul>
      <a
        v-else
        href="/tasks/biological_relationships/composer">Create new</a>
    </div>
  </div>
</template>

<script>

import { URLParamsToJSON } from 'helpers/url/parse.js'
import { BiologicalRelationship } from 'routes/endpoints'

export default {
  props: {
    value: {
      type: Array,
      required: true
    }
  },
  computed: {
    inRelationships: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      biologicalRelationships: [],
      relationshipSelected: []
    }
  },
  mounted () {
    BiologicalRelationship.all().then(response => {
      this.biologicalRelationships = response.body
    })
    const urlParams = URLParamsToJSON(location.href)
    this.inRelationships = urlParams.biological_relationship_ids ? urlParams.biological_relationship_ids : []
  }
}
</script>
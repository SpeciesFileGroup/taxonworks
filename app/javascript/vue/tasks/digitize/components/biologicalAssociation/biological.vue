<template>
  <fieldset class="full_width">
    <legend>Biological relationship</legend>
    <div class="horizontal-left-content middle margin-medium-bottom">
      <switch-component
        class="full_width"
        v-model="view"
        name="biological"
        :add-option="['search']"
        :options="Object.keys(list)"/>
      <pin-default
        class="separate-left"
        section="BiologicalRelationships"
        @getItem="$emit('select', { id: $event.id, name: $event.label })"
        type="BiologicalRelationship"/>
    </div>
    <template v-if="view && list && list[view]">
      <tag-item 
        v-for="item in list[view]"
        :key="item.id"
        display="name"
        :class="{ 'button-default': selected == item}"
        :item="item"
        @select="$emit('select',item)"/>
    </template>
    <autocomplete
      v-else
      url="/biological_relationships/autocomplete"
      label="label"
      min="2"
      @getItem="$emit('select', $event)"
      placeholder="Select a biological relationship"
      param="term"/>
  </fieldset>
</template>

<script>

  import TagItem from '../shared/item_tag.vue'
  import SwitchComponent from 'components/switch.vue'
  import Autocomplete from 'components/autocomplete.vue'
  import PinDefault from 'components/getDefaultPin.vue'
  import { GetBiologicalRelationshipsSmartSelector, GetBiologicalRelationships } from '../../request/resources.js'
  
  export default {
    components: {
      TagItem,
      SwitchComponent,
      Autocomplete,
      PinDefault
    },
    data() {
      return {
        view: undefined,
        selected: undefined,
        orderTabs: ['quick','recent', 'pinboard', 'all', 'search'],
        list: {}
      }
    },
    mounted() {
      this.loadTabList();
    },
    methods: {
      loadTabList() {
        let promises = []
        let that = this
        let result
        let allList

        promises.push(GetBiologicalRelationshipsSmartSelector().then(response => {
          result = response
        }))
        promises.push(GetBiologicalRelationships().then(response => {
          allList = response
        }))
        Promise.all(promises).then(() => {
          result['all'] = allList
          Object.keys(result).forEach(key => (!result[key].length) && delete result[key])
          
          let reorderList = {}

          that.orderTabs.forEach((key) => {
            if(result.hasOwnProperty(key))
              reorderList[key] = result[key]
          })

          that.list = reorderList;

          if(Object.keys(result).length) {
            that.view = Object.keys(result)[0]
          }
          else {
            that.view = 'search'
          }
        })
      },
    }
  }
</script>
<template>
  <div>
    <fieldset>
      <legend>Biological relationship</legend>
      <switch-component 
        v-model="view"
        name="biological"
        :add-option="['search']"
        :options="Object.keys(list)"/>

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
  </div>
</template>

<script>

  import TagItem from '../shared/item_tag.vue'
  import SwitchComponent from '../shared/switch.vue'
  import CRUD from '../../request/crud.js'
  import Autocomplete from 'components/autocomplete.vue'
  
  export default {
    mixins: [CRUD],
    components: {
      TagItem,
      SwitchComponent,
      Autocomplete
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

        promises.push(this.getList(`/biological_relationships/select_options`).then(response => {
          result = response.body
        }))
        promises.push(this.getList(`/biological_relationships.json`).then(response => {
          allList = response.body
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
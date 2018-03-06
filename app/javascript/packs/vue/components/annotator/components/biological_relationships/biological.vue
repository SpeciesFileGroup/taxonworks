<template>
  <div>
    <h3>Biological relationship</h3>
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
  </div>
</template>

<script>

  import TagItem from '../shared/item_tag.vue'
  import SwitchComponent from '../shared/switch.vue'
  import CRUD from '../../request/crud.js'
  import Autocomplete from '../../../autocomplete.vue'
  
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
        list: {}
      }
    },
    mounted() {
      this.loadTabList();
    },
    methods: {
      loadTabList() {
        this.getList(`/biological_relationships/select_options`).then(response => {
          let result = response.body
          Object.keys(result).forEach(key => (!result[key].length) && delete result[key])
          this.list = result;
          if(Object.keys(result).length) {
            this.view = Object.keys(result)[0]
          }
          else {
            this.view = 'search'
          }
        })
      },
    }
  }
</script>
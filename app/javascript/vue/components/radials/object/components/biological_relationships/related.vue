<template>
  <div>
    <fieldset>
      <legend>Related</legend>
      <switch-component
        :options="tabOptions"
        v-model="view"
        name="related"/>
      <template v-if="otuView">
        <switch-component
          :options="Object.keys(smartOtu)"
          v-model="viewOtu"
          :add-option="['search']"
          name="switch-otu"/>
        <template v-if="smartOtu[viewOtu]">
          <tag-item
            v-for="item in smartOtu[viewOtu]"
            :item="item"
            :class="{ 'button-default': selected == item.id }"
            display="object_tag"
            @select="sendRelated(item)"
            :key="item.id"/>
        </template>
        <otu-autocomplete
          v-else
          @getItem="sendRelated($event)"/>
      </template>

      <template v-else>
        <switch-component
          :options="Object.keys(smartCollectionObject)"
          v-model="viewCollectionObject"
          :add-option="['search']"
          name="switch-collection"/>
        <template v-if="smartCollectionObject[viewCollectionObject]">
          <tag-item
            v-for="item in smartCollectionObject[viewCollectionObject]"
            :item="item"
            :class="{ 'button-default': selected == item.id }"
            display="object_tag"
            @select="sendRelated(item)"
            :key="item.id"/>
        </template>
        <autocomplete
          v-else
          url="/collection_objects/autocomplete"
          label="label_html"
          min="2"
          @getItem="sendRelated($event)"
          placeholder="Select a collection object"
          param="term"/>
      </template>
    </fieldset>
  </div>
</template>

<script>

  import OtuAutocomplete from 'components/otu/otu_picker/otu_picker.vue'
  import TagItem from '../shared/item_tag.vue'
  import SwitchComponent from '../shared/switch.vue'
  import Autocomplete from 'components/ui/Autocomplete.vue'
  import CRUD from '../../request/crud'

  export default {
    mixins: [CRUD],
    components: {
      TagItem,
      SwitchComponent,
      Autocomplete,
      OtuAutocomplete
    },
    computed: {
      otuView() {
        return this.view === 'otu'
      }
    },
    data() {
      return {
        view: 'otu',
        viewOtu: undefined,
        viewCollectionObject: undefined,
        tabOptions: ['otu', 'collection object'],
        smartOtu: [],
        smartCollectionObject: [],
        selected: undefined
      }
    },
    mounted() {
      this.getList(`/otus/select_options?target=BiologicalAssociation`).then(response => {
        let result = response.body
        Object.keys(result).forEach(key => (!result[key].length) && delete result[key])
        this.smartOtu = result
        this.viewOtu = this.firstTabWithData(result);
      })
      this.getList(`/collection_objects/select_options?target=BiologicalAssociation`).then(response => {
        let result = response.body
        Object.keys(result).forEach(key => (!result[key].length) && delete result[key])
        this.smartCollectionObject = result
        this.viewCollectionObject = this.firstTabWithData(result);
      })
    },
    methods: {
      sendRelated(item) {
        this.selected = item.id
        item['type'] = (this.otuView ? 'Otu' : 'CollectionObject')
        if(item.hasOwnProperty('gid')) {
          item['global_id'] = item.gid
        }
        this.$emit('select', item)
      },
      firstTabWithData(smartObject) {
        if(Object.keys(smartObject).length) {
          return Object.keys(smartObject)[0]
        }
        else {
          return 'search'
        }        
      }
    }
  }
</script>
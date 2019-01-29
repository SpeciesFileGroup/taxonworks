
<template>
  <div>
    <fieldset>
      <legend>Geographic area</legend>
      <switch-component
        :options="Object.keys(smartGeographics)"
        v-model="view"
        :add-option="['search']"
        name="switch-geographic"/>
      <template v-if="smartGeographics[view]">
        <tag-item
          v-for="item in smartGeographics[view]"
          :item="item"
          display="name"
          @select="sendGeographic"
          :key="item.id"/>
      </template>
      <autocomplete
        v-else
        url="/geographic_areas/autocomplete"
        label="label_html"
        min="2"
        :clear-after="true"
        :autofocus="true"
        @getItem="sendGeographic"
        placeholder="Select a geographic area"
        param="term"/>
    </fieldset>
  </div>
</template>

<script>

  import TagItem from '../shared/item_tag.vue'
  import SwitchComponent from '../shared/switch.vue'
  import Autocomplete from 'components/autocomplete.vue'
  import CRUD from '../../request/crud'

  export default {
    mixins: [CRUD],
    components: {
      TagItem,
      SwitchComponent,
      Autocomplete
    },
    props: {
      createdList: {
        type: Array,
        required: true
      }
    },
    data() {
      return {
        view: undefined,
        smartGeographics: [],
        selected: undefined
      }
    },
    mounted() {
      this.getList(`/geographic_areas/select_options?target=AssertedDistribution`).then(response => {
        let result = response.body
        Object.keys(result).forEach(key => (!result[key].length) && delete result[key])
        this.smartGeographics = result
        this.view = this.firstTabWithData(result);
      })
    },
    methods: {
      sendGeographic(item) {
        this.selected = ''
        this.$emit('select', item.id)
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

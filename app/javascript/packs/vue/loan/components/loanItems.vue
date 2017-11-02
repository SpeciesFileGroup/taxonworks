<template>
    <div class="panel loan-box">
      <div class="header flex-separate middle">
        <h3 class="">Loan items</h3>
        <expand v-model="displayBody"></expand>
      </div>
      <div class="body" v-if="displayBody">
      <div class="switch-radio">
        <template v-for="item, index in typeList">
          <input 
            v-model="displaySection"
            :value="index"
            :id="`loan-picker-${index}`" 
            name="loan-picker-options"
            type="radio"
            class="normal-input button-active" 
          />
          <label :for="`loan-picker-${index}`" class="capitalize">{{ item }}</label>
        </template>
      </div>

        <div v-if="displaySection == 0">
          <p>Select loan item type</p>
          <div class="field">
            <label>
              <input type="radio" v-model="objectType" name="autocomplete_type" value="collection_objects" checked/>
              Collection object
            </label>
            <label>
              <input type="radio" v-model="objectType" name="autocomplete_type" value="otus"/>
              OTU
            </label>
            <label>
              <input type="radio" v-model="objectType" name="autocomplete_type" value="containers"/>
              Container
            </label>
          </div>
          <div class="field">
            <autocomplete
              min="2"
              placeholder="Select loan item"
              label="label"
              :url="autocomplete_type[objectType]"
              param="term">
            </autocomplete>
          </div>
        </div>

        <div v-if="displaySection == 1">
          <div v-for="item, key in keywords">
            <p v-html="item.object.object_tag"></p>
            <ul>
              <li v-for="object, key in item.totals">
                <span class="capitalize">{{ key }}: {{ object }}</span>
              </li>
            </ul>
          </div>
        </div>

      </div>
    </div>
</template>

<script>
  import autocomplete from '../../components/autocomplete.vue';
  import expand from './expand.vue';

  import { getTagMetadata } from '../request/resources';
  
  export default {
    components: {
      expand,
      autocomplete
    },
    mounted: function() {
      var that = this;

      getTagMetadata().then(response => {
        that.info = response;
        that.keywords = response.keywords;
        that.pinboard = response.pinboard;
      })
    },
    data: function() {
      return {
        typeList: [
          'By object',
          'By tag',
          'By pinboard',
        ],
        keywords: undefined,
        pinboard: undefined,
        info: undefined,
        displaySection: 0,
        displayBody: true,
        objectType: 'otus',
        autocomplete_type: {
          otus: '/otus/autocomplete',
          containers: '/containers/autocomplete',
          collection_objects: '/collection_objects/autocomplete'
        },
        loan_item: {
          loan_id: undefined, 
          collection_object_status: undefined, 
          date_returned: undefined, 
          loan_item_object_id: undefined, 
          loan_item_object_type: undefined,
          disposition: undefined, 
          total: undefined,
          global_entity: undefined,
          position: undefined
        }
      }
    }
  }
</script>
<style lang="scss">
  #edit_loan_task {
    .switch-radio {
      label {
        width: 100px;
      }
    }
  }
</style>
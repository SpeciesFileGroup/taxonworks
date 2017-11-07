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
              <input type="radio" v-model="loan_item.loan_item_object_type" name="autocomplete_type" value="CollectionObject" checked/>
              Collection object
            </label>
            <label>
              <input type="radio" v-model="loan_item.loan_item_object_type" name="autocomplete_type" value="Otu"/>
              OTU
            </label>
            <label>
              <input type="radio" v-model="loan_item.loan_item_object_type" name="autocomplete_type" value="Container"/>
              Container
            </label>
          </div>
          <div class="field">
            <autocomplete
              min="2"
              placeholder="Select loan item"
              label="label"
              :disabled="!loan_item.loan_item_object_type"
              @getItem="loan_item.loan_item_object_id = $event.id"
              :url="autocomplete_type[loan_item.loan_item_object_type]"
              param="term">
            </autocomplete>
          </div>
          <div>
            <div class="field">
              <label>Status</label>
              <select v-model="loan_item.disposition" class="normal-input">
                <option  v-for="item in statusList" :value="item">{{ item }}</option>
              </select>
            </div>
            <div class="field">
              <label>Date returned</label>
              <input v-model="loan_item.date_returned" type="date"/>
            </div>
            <div class="field">
              <label>Total</label>
              <input v-model="loan_item.total" class="normal-input" type="text"/>
            </div>
          </div>
          <button class="normal-input button button-submit" type="button" @click="createItem()">Create</button>
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

        <display-list :list="loanItems" @delete="deleteItem" label="object_tag"></display-list>
      </div>
    </div>
</template>

<script>

  import displayList from './displayList.vue';
  import autocomplete from '../../components/autocomplete.vue';
  import expand from './expand.vue';

  import { getTagMetadata, createLoanItem } from '../request/resources';
  import ActionNames from '../store/actions/actionNames';
  import { GetterNames } from '../store/getters/getters';
  import { MutationNames } from '../store/mutations/mutations';
  
  export default {
    components: {
      expand,
      autocomplete,
      displayList
    },
    computed: {
      loanItems() {
        return this.$store.getters[GetterNames.GetLoanItems]
      },
      loan() {
        return this.$store.getters[GetterNames.GetLoan]
      }
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
        statusList: [
          'Destroyed',
          'Donated',
          'Loaned on',
          'Lost',
          'Retained',
          'Returned'
        ],
        keywords: undefined,
        pinboard: undefined,
        info: undefined,
        displaySection: 0,
        displayBody: true,
        autocomplete_type: {
          Otu: '/otus/autocomplete',
          Container: '/containers/autocomplete',
          CollectionObject: '/collection_objects/autocomplete'
        },
        loan_item: this.newLoanItem()
      }
    },
    methods: {
      newLoanItem() {
        return {
          loan_id: undefined, 
          date_returned: undefined, 
          loan_item_object_id: undefined, 
          loan_item_object_type: undefined,
          disposition: undefined, 
          total: undefined,
          position: undefined          
        }
      },
      createItem() {
        var that = this;
        this.loan_item.loan_id = this.loan.id;

        createLoanItem(this.loan_item).then(response => {
          that.$store.commit(MutationNames.AddLoanItem, response);
          console.log(response);
        });
      },
      deleteItem(item) {
        this.$store.dispatch(ActionNames.DeleteLoanItem, item.id)
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
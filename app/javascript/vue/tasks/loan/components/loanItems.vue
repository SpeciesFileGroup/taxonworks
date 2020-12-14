<template>
  <div class="panel loan-box">
    <spinner
      :show-spinner="false"
      :resize="false"
      :show-legend="false"
      v-if="!loan.id"/>
    <div class="header flex-separate middle">
      <h3>Add loan items</h3>
      <expand v-model="displayBody"/>
    </div>
    <div
      class="body"
      v-if="displayBody">
      <div class="switch-radio">
        <template
        v-for="(item, index) in typeList">
          <input
            v-model="displaySection"
            :value="index"
            :id="`loan-picker-${index}`"
            name="loan-picker-options"
            type="radio"
            class="normal-input button-active"
          >
          <label
            :for="`loan-picker-${index}`"
            class="capitalize">{{ item }}
          </label>
        </template>
      </div>

      <div v-if="displaySection == 0">
        <p>Select loan item type</p>
        <div class="field">
          <label class="label-flex">
            <input
              type="radio"
              v-model="loan_item.loan_item_object_type"
              name="autocomplete_type"
              value="CollectionObject"
              checked>
            Collection object
          </label>
          <label class="label-flex">
            <input
              type="radio"
              v-model="loan_item.loan_item_object_type"
              name="autocomplete_type"
              value="Otu">
            OTU
          </label>
          <label class="label-flex">
            <input
              type="radio"
              v-model="loan_item.loan_item_object_type"
              name="autocomplete_type"
              value="Container">
            Container
          </label>
        </div>
        <div class="field">
          <autocomplete
            min="2"
            placeholder="Select loan item"
            label="label_html"
            display="label"
            :disabled="!loan_item.loan_item_object_type"
            @getItem="loan_item.loan_item_object_id = $event.id"
            :url="autocomplete_type[loan_item.loan_item_object_type]"
            param="term"/>
        </div>
        <div>
          <div
            class="field"
            v-if="loan_item.loan_item_object_type == 'Otu'">
            <label>Total</label>
            <input
              v-model="loan_item.total"
              class="normal-input"
              type="text">
          </div>
        </div>
        <button
          class="normal-input button button-submit"
          type="button"
          @click="createItem()">Create
        </button>
      </div>

      <div v-if="displaySection == 1">
        <div v-for="(item) in keywords">
          <hr>
          <b><p v-html="item.object.object_tag"/></b>
          <div
            class="tag_list"
            v-for="(object, key) in item.totals"
            v-if="object">
            <div class="capitalize tag_label">{{ key }}</div>
            <div class="tag_total">{{ object }}</div>
            <button
              class="button normal-input button-submit"
              type="button"
              @click="batchLoad(key, item.object.id, 'tags', object)">Create
            </button>
            <button
              v-if="key != 'total'"
              class="separate-left button normal-input button-delete"
              type="button"
              @click="removeKeyword(item.object.id, key)">Remove
            </button>
          </div>
        </div>
      </div>

      <div v-if="displaySection == 2">
        <div
          class="tag_list"
          v-for="(object, key) in pinboard.totals"
          v-if="object">
          <div class="capitalize tag_label">{{ key }}</div>
          <div class="tag_total"> {{ object }}</div>
          <button
            class="button normal-input button-submit"
            type="button"
            @click="batchLoad(key, undefined, 'pinboard', object)">Create
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

  import autocomplete from 'components/autocomplete.vue'
  import spinner from 'components/spinner.vue'
  import expand from './expand.vue'

  import statusList from '../helpers/status.js'

  import { getTagMetadata, createLoanItem, batchRemoveKeyword } from '../request/resources'
  import ActionNames from '../store/actions/actionNames'
  import { GetterNames } from '../store/getters/getters'
  import { MutationNames } from '../store/mutations/mutations'

  export default {
    components: {
      expand,
      spinner,
      autocomplete
    },
    computed: {
      loan() {
        return this.$store.getters[GetterNames.GetLoan]
      }
    },
    mounted: function () {
      this.getMeta()
    },
    data: function () {
      return {
        maxItemsWarning: 100,
        typeList: [
          'By object',
          'By tag',
          'By pinboard'
        ],
        statusList: statusList,
        selectedItems: [],
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
          loan_item_object_id: undefined,
          loan_item_object_type: undefined,
          total: undefined,
          position: undefined
        }
      },
      getMeta() {
        let that = this

        return getTagMetadata().then(response => {
          that.info = response.body
          that.keywords = response.body.keywords
          that.pinboard = response.body.pinboard
        })
      },
      removeKeyword(id, type) {
        let that = this
        this.$store.commit(MutationNames.SetSaving, true)
        batchRemoveKeyword(id, type).then(response => {
          that.getMeta().then(response => {
            this.$store.commit(MutationNames.SetSaving, false)
          })
        })
      },
      createItem() {
        var that = this
        this.loan_item.loan_id = this.loan.id

        createLoanItem({loan_item: this.loan_item}).then(response => {
          that.$store.commit(MutationNames.AddLoanItem, response.body)
          TW.workbench.alert.create('Loan item was successfully created.', 'notice')
        })
      },
      batchLoad(klass, keyword, type, total) {
        let object = {
          batch_type: type,
          loan_id: this.loan.id,
          keyword_id: keyword,
          klass: (klass == 'total' ? undefined : klass)
        }
        if (total > this.maxItemsWarning) {
          if (window.confirm(`You're trying to create ${total} items. Are you sure want to proceed?`)) {
            this.$store.dispatch(ActionNames.CreateBatchLoad, object)
          }
        } else {
          this.$store.dispatch(ActionNames.CreateBatchLoad, object)
        }
      },
      deleteItem(item) {
        this.$store.dispatch(ActionNames.DeleteLoanItem, item.id)
      }
    }
  }
</script>
<style lang="scss" scoped>
  #edit_loan_task {
    .label-flex {
      display: flex;
      align-items: center;
    }
    .switch-radio {
      label {
        width: 100px;
      }
    }
    .tag_list {
      margin-top: 0.5em;
      align-items: center;
      text-align: right;
      display: flex;
      .tag_label {
        width: 130px;
        min-width: 130px;
      }
      .tag_total {
        margin-left: 1em;
        margin-right: 1em;
        text-align: left;
        min-width: 50px;
      }
    }
  }
</style>

<template>
  <div>
    <autocomplete
      url="/taxon_names/autocomplete"
      label="label_html"
      min="2"
      eventSend="parentSelected"
      display="label"
      :sendLabel="parent.name"
      param="term">
    </autocomplete>
    <div class="field" v-if="!taxon.id && parent && parent.parent_id == null">
      <h4>Nomenclature code</h4>
      <ul class="no_bullets">
        <li v-for="code in getCodes">
          <label class="middle uppercase">
            <input type="radio" name="rankSelected" v-model="nomenclatureCode" :value="code"/> {{code}}
          </label>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
  const autocomplete = require('../../../components/autocomplete.vue');
  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;
  const ActionNames = require('../store/actions/actions').ActionNames;

  var foundRankGroup = require('../helpers/foundRankGroup');
  var truncateAtRank = require('../helpers/truncateAtRank');

  export default {
    components: {
      autocomplete
    },
    computed: {
      taxon() {
        return this.$store.getters[GetterNames.GetTaxon]
      },
      parent: {
        get() {
          let value = this.$store.getters[GetterNames.GetParent];
          return (value != undefined ? value : '');
        }
      },
      getCodes: {
        get() {
          let codes = Object.keys(this.$store.getters[GetterNames.GetRankList]);
          return (codes != undefined ? codes : '');
        }
      },
      nomenclatureCode: {
        get() {
          this.$store.getters[GetterNames.GetNomenclatureCode]
        },
        set(value) {
          this.$store.commit(MutationNames.SetNomenclaturalCode, value),
          this.setParentRank(this.parent)
        }
      }
    },
    data: function() {
      return {
        code: undefined,
      }
    },
    mounted: function() {
      var that = this;
      this.$on('parentSelected', function(item) {
       this.$store.commit(MutationNames.SetParentId, item.id);
       this.$http.get(`/taxon_names/${item.id}`).then( response => {
        if(response.body.parent_id != null) {
          this.$store.commit(MutationNames.SetNomenclaturalCode, response.body.nomenclatural_code);
          this.setParentRank(response.body);
        }
        else {
          this.$store.commit(MutationNames.SetParent, response.body)
        }
      });
     });
    },
    methods: {
      setParentRank: function(parent) {
        this.$store.commit(MutationNames.SetRankClass, undefined);
        this.$store.dispatch(ActionNames.SetParentAndRanks, parent);
        this.$store.commit(MutationNames.UpdateLastChange)      
      }
    }
  };
</script>
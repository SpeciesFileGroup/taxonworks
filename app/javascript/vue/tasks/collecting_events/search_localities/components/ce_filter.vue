<template>
  <div class="find-ce">
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <h3>Find collecting events</h3>
    <table>
      <tbody>
        <tr>
          <td>Originating<br>on exactly</td>
          <td>Day</td>
          <td>Month</td>
          <td>Year</td> 
          <td>between start date</td>
        </tr>
        <tr>
          <td/>
          <td>
            <input
              v-model="parameters['start_date_day']"
              type=text
              size="2"
              maxlength="2">
          </td>
          <td>
            <month-select @month="parameters['start_date_month']=$event"/>
          </td>
          <td>
            <input
              v-model="parameters['start_date_year']"
              type=text
              size="4"
              maxlength="4">
          </td>
          <td> &nbsp; OR &nbsp; </td>
          <td>
            <input
              id="vueStartDate"
              v-model="parameters['start_date']"
              type="date">
            <button
              type="button"
              class="button normal-input button-default separate-left"
              @click="setTodaysDateForStart">
              Now
            </button>
          </td>
        </tr>
        <tr>
          <td>And ending<br>on exactly</td>
          <td>Day</td>
          <td>Month</td>
          <td>Year</td>
          <td>and end date</td>
        </tr>
        <tr>
          <td/>
          <td>
            <input
              v-model="parameters['end_date_day']"
              type="text"
              size="2"
              maxlength="2">
          </td>
          <td>
            <month-select @month="parameters['end_date_month']=$event"/>
          </td>
          <td>
            <input
              v-model="parameters['end_date_year']"
              type="text"
              size="4"
              maxlength="4">
          </td>
          <td/>
          <td>
            <input
              id="vueEndDate"
              v-model="parameters['end_date']"
              type="date">
            <button
              type="button"
              class="button normal-input button-default separate-left"
              @click="setTodaysDateForEnd">
              Now
            </button>
          </td>
        </tr>
      </tbody>
    </table>
    <table>
      <tr>
        <td class="field">
          <label>Verbatim locality containing</label>
        </td>
        <td>
          <input
            v-model="parameters['in_verbatim_locality']"
            type="text"
            size="35">
        </td>
      </tr>
      <tr>
        <td class="field">
          <label>Any label containing</label>
        </td>
        <td>
          <input
            v-model="parameters['in_labels']"
            type="text"
            size="35">
        </td>
      </tr>
      <tr>
        <td class="field">
          <label>An identifier containing</label>
        </td>
        <td>
          <input
            v-model="parameters['identifier_text']"
            type="text"
            size="35">
        </td>
      </tr>
    </table>
    <input
      class="button normal-input button-default separate-left"
      type="button"
      @click="getFilterData()"
      :disabled="!haveParams"
      value="Find"
    >
  </div>
</template>
<script>
  import MonthSelect from './month_select'
  import Spinner from 'components/spinner'

  export default {
    components: {
      MonthSelect,
      Spinner
    },
    data() {
      return {
        parameters: {
          start_date_day: '',
          end_date_day: '',
          start_date_month: '',
          end_date_month: '',
          start_date_year: '',
          end_date_year: '',
          start_date: '',
          end_date: '',
          in_verbatim_locality: '',
          in_labels: '',
          identifier_text: '',
          shape: ''},
        collectingEventList: [],
        isLoading:  false,
        haveParams: false,
      }
    },
    watch: {
      parameters: {
        handler(newVal) {
          this.disableFind();
        },
        deep: true
      }
    },
    methods: {
      setTodaysDateForStart() {
        this.parameters.start_date = this.makeISODate(new Date());
      },
      setTodaysDateForEnd() {
        this.parameters.end_date = this.makeISODate(new Date());
      },
      getFilterData(){
        let params = {};
        let keys = Object.keys(this.parameters);
        for (let i=0; i<keys.length; i++) {
            if (this.parameters[keys[i]].length) {
              params[keys[i]] = this.parameters[keys[i]];
            }
        }
        this.isLoading = true;
        this.$http.get('/collecting_events.json', { params: params }).then(response => {
          this.collectingEventList = response.body;
          if(this.collectingEventList) {
            this.$emit('collectingEventList', this.collectingEventList)
          }
          this.isLoading = false;
        });
      },
      showObject(id) {
          window.open(`/collecting_events/` + id, '_blank');
      },
      makeISODate(date) {
        return date.toISOString().slice(0,10)
      },
      disableFind() {
        let haveParams = 0;
        let i = 0;
        let paramKeys = Object.keys(this.parameters);
        for (i=0; i < paramKeys.length; i++) {
          haveParams += this.parameters[paramKeys[i]].length;
        }
        this.haveParams = (haveParams > 0);
      }
    },
  }
</script>

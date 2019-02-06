<template>
  <div class="find-ce">
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <h3>Find collecting events</h3>
    <table>
      <tr>
        <td>Originating<br>between</td><td>Day</td><td>Month</td><td>Year</td><td>DatePicker</td><td/>
      </tr>
      <tr>
        <td/>
        <td>
          <input
            v-model="parameters['start_day']"
            type=text
            size="2"
            maxlength="2">
        </td>
        <!--<td>-->
          <!--<month-select @month="parameters['start_month']=$event"/>-->
        <!--</td>-->
        <td>
          <input
            v-model="parameters['start_month']"
            type=text
            size="2"
            maxlength="2">
        </td>
        <td>
          <input
            v-model="parameters['start_year']"
            type=text
            size="4"
            maxlength="4">
        </td>
        <td>
          <input
            v-model="parameters['start_date']"
            type="date">
        </td>
        <td>
          <button
            type="button"
            class="button normal-input button-default separate-left"
            @click="setActualDateForStart">
            Now
          </button>
        </td>
      </tr>
      <tr>
        <td>And</td><td>Day</td><td>Month</td><td>Year</td><td>DatePicker</td><td/>
      </tr>
      <tr>
        <td/>
        <td>
          <input
            v-model="parameters['end_day']"
            type=text
            size="2"
            maxlength="2">
        </td>
        <td>
          <!--<month-select @month="parameters['end_month']=$event"/>-->
          <input
            v-model="parameters['end_month']"
            type=text
            size="2"
            maxlength="2">
        </td>
        <td>
          <input
            v-model="parameters['end_year']"
            type=text
            size="4"
            maxlength="4">
        </td>
        <td>
          <input
            v-model="parameters['end_date']"
            type="date">
        </td>
        <td>
          <button
            type="button"
            class="button normal-input button-default separate-left"
            @click="setActualDateForEnd">
            Now
          </button>
        </td>
      </tr>
    </table>
    <table>
      <tr>
        <td class="field">
          <label>Verbatim locality containing</label>
        </td>
        <td>
          <input
            v-model="parameters['in_verbatim_locality']"
            type=text
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
            type=text
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
            type=text
            size="35">
        </td>
      </tr>
    </table>
    <input
      type="button" class="button normal-input button-default separate-left"
      @click="getFilterData()"
      value="Find">
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
          start_day: '',
          end_day: '',
          start_month: '',
          end_month: '',
          start_year: '',
          end_year: '',
          start_date: '',
          end_date: '',
          in_verbatim_locality: '',
          iin_labels: '',
          identifier_text: '',
          shape: ''},
        collectingEventList: [],
        isLoading:  false,
      }
    },

    methods: {
      setActualDateForStart() {
        let today = new Date();
        this.parameters.start_day = today.getDate().toString();
        this.parameters.start_month = (today.getMonth() + 1).toString();
        this.parameters.start_year = today.getFullYear().toString();
        // this.parameters.start_date = this.makeDate(this.start_year, this.start_month, this.start_day);
      },
      setActualDateForEnd() {
        let today = new Date();
        this.parameters.end_day = today.getDate().toString();
        this.parameters.end_month = (today.getMonth() + 1).toString();
        this.parameters.end_year = today.getFullYear().toString();
        // this.parameters.end_date = this.makeDate(this.end_year, this.end_month, this.end_day);
      },
      getFilterData(){
        // if((this.start_year + this.start_month + this.start_day).length) {
        //   this.parameters.start_date = this.makeDate(this.start_year, this.start_month, this.start_day);
        // }
        // if((this.end_year + this.end_month + this.end_day).length) {
        //   this.parameters.end_date = this.makeDate(this.end_year, this.end_month, this.end_day);
        // }
        let params = {};
        let keys = Object.keys(this.parameters);
        for (let i=0; i<keys.length; i++) {
            if (this.parameters[keys[i]].length) {
              params[keys[i]] = this.parameters[keys[i]];
            }
        }
        // params = this.parameters;
        //   start_date_day: this.start_date_day,
        //   end_date_day: this.end_date_day,
        //   start_date_month: this.start_date_month,
        //   end_date_month: this.end_date_month,
        //   start_date_year: this.start_date_year,
        //   end_date_year: this.end_date_year,
        //   start_date: this.st_datepicker,
        //   end_date: this.en_datepicker,
        //   verbatim_locality_text: this.verbatim_locality_text,
        //   in_labels: this.any_label_text,
        //   identifier_text: this.identifier_text,
        // };
        this.isLoading = true;
        this.$http.get('/collecting_events.json', {params: params}).then(response => {
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
      makeDate(year, month, day) {
       return year + '-' + month + '-' + day;
      }
    }
  }
</script>

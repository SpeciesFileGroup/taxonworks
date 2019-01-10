<template>
  <div class="find-ce">
    <h3>Find collecting events</h3>
    <table>
      <tr>
        <td>Originating<br>between</td><td>Day</td><td>Month</td><td>Year</td><td>DatePicker</td>
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
        <td>
          <input
            v-model="parameters['start_date']"
            type="date">
        </td>
      </tr>
      <tr>
        <td>And</td><td>Day</td><td>Month</td><td>Year</td><td>DatePicker</td>
      </tr>
      <tr>
        <td/>
        <td>
          <input
            v-model="parameters['end_date_day']"
            type=text
            size="2"
            maxlength="2">
        </td>
        <td>
          <month-select @month="parameters['end_date_month']=$event"/>
        </td>
        <td>
          <input
            v-model="parameters['end_date_year']"
            type=text
            size="4"
            maxlength="4">
        </td>
        <td>
          <input
            v-model="parameters['end_date']"
            type="date">
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
      type="button"
      @click="getFilterData()"
      value="Find">
    <div>
      <span v-if="collectingEventList.length" v-html="'<br>' + collectingEventList.length + '  results found.'"/>
      <table>
        <th>Cached</th><th>verbatim locality</th>
        <tr
          v-for="item in collectingEventList"
          :key="item.id">
          <td>
            <span
              v-html="item.id + ' ' + item.cached"
              @click="showObject(item.id)"
            />
          </td>
          <td><span v-html="item.verbatim_locality" /></td>
        </tr>
      </table>
    </div>
  </div>
</template>
<script>
  import MonthSelect from './month_select'

  export default {
    components: {
      MonthSelect
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
          iin_labels: '',
          identifier_text: '',
          shape: ''},
        collectingEventList: []
      }
    },

    methods: {
      getFilterData(){
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
        this.$http.get('/collecting_events.json', {params: params}).then(response => {
          this.collectingEventList = response.body;
        });
      },
        showObject(id) {
            window.open(`/collecting_events/` + id, '_blank');
        },
    }
  }
</script>

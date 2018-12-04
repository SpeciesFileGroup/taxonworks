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
            v-model="start_date_day"
            type=text
            size="2"
            maxlength="2">
        </td>
        <td>
          <month-select @month="start_date_month=$event"/>
        </td>
        <td>
          <input
            v-model="start_date_year"
            type=text
            size="4"
            maxlength="4">
        </td>
        <td>
          <input
            v-model="st_datepicker"
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
            v-model="end_date_day"
            type=text
            size="2"
            maxlength="2">
        </td>
        <td>
          <month-select @month="end_date_month=$event"/>
        </td>
        <td>
          <input
            v-model="end_date_year"
            type=text
            size="4"
            maxlength="4">
        </td>
        <td>
          <input
            v-model="en_datepicker"
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
            v-model="verbatim_locality_text"
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
            v-model="any_label_text"
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
            v-model="identifier_text"
            type=text
            size="35">
        </td>
      </tr>
    </table>
    <input
      type="button"
      @click="gettFilterData()"
      value="Find">
    <div>
      <table>
        <tr
          v-for="item in filterList"
          :key="item">
          <td>
            <span
              v-html="item.verbatim_locality"/>
          </td>
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
        start_date_day: '',
        end_date_day: '',
        start_date_month: '',
        end_date_month: '',
        start_date_year: '',
        end_date_year: '',
        st_datepicker: '',
        en_datepicker: '',
        verbatim_locality_text: '',
        any_label_text: '',
        identifier_text: '',
        filterList: []
      }
    },

    methods: {
      gettFilterData(){
        let params = {
          start_date_day: this.start_date_day,
          end_date_day: this.end_date_day,
          start_date_month: this.start_date_month,
          end_date_month: this.end_date_month,
          start_date_year: this.start_date_year,
          end_date_year: this.end_date_year,
          st_datepicker: this.st_datepicker,
          en_datepicker: this.en_datepicker,
          verbatim_locality_text: this.verbatim_locality_text,
          any_label_text: this.any_label_text,
          identifier_text: this.identifier_text,
        };
        this.$http.get('/collecting_events', {params: params}).then(response => {
          this.filterList = response.body.html;
        });
      }
    }
  }
</script>

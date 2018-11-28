<template>
  <div class="find-ce">
    <h3>Find collecting events</h3>
    <table>
      <tr>
        <td>Originating<br>between</td><td>Day</td><td>Month</td><td>Year</td><td>DatePicker</td>
      </tr>
      <tr>
        <td></td>
        <td>
          <input v-model="start_day" type=text size="2" maxlength="2" />
        </td>
        <td>
          <month-select @month="start_month=$event"/>
        </td>
        <td>
          <input v-model="start_year" type=text size="4" maxlength="4" />
        </td>
        <td><input v-model="start_mdy" type="date"></td>
      </tr>
      <tr>
        <td>And</td><td>Day</td><td>Month</td><td>Year</td><td>DatePicker</td>
      </tr>
      <tr>
        <td></td>
        <td>
          <input v-model="end_day" type=text size="2" maxlength="2"/>
        </td>
        <td>
          <month-select @month="end_month=$event"/>
        </td>
        <td>
          <input v-model="end_year" type=text size="4" maxlength="4"/>
        </td>
        <td><input v-model="end_mdy" type="date"></td>
      </tr>
    </table>
    <table>
      <tr>
        <td class="field">
          <label for="verbatim_locality_text">Verbatim locality containing</label>
        </td>
        <td>
          <input v-model="verbatim_locality_text" type=text size="35"/>
        </td>
      </tr>
      <tr>
        <td class="field"><label for="any_label_text">Any label containing</label></td>
        <td>
          <input v-model="any_label_text" type=text size="35"/>
        </td>
      </tr>
      <tr>
        <td class="field">
          <label for="identifier_text">An identifier containing</label>
        </td>
        <td>
          <input v-model="identifier_text" type=text size="35"/>
        </td>
      </tr>
    </table>

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
        start_day: '',
        end_day: '',
        start_month: '',
        end_month: '',
        start_year: '',
        end_year: '',
        start_mdy: '',
        end_mdy: '',
        verbatim_locality_text: '',
        any_label_text: '',
        identifier_text: ''
      }
    },
  }
</script>

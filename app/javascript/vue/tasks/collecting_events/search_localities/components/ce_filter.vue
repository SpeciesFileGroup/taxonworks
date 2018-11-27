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
          <input type=text id="start_date_day" name="start_date_day" size="2" maxlength="2" />
        </td>
        <td>
          <month-select name="start_date_month"/>
        </td>
        <td>
          <input type=text id="start_date_year" name="start_date_year" size="4" maxlength="4" />
        </td>
        <td><input type="date"></td>
      </tr>
      <tr>
        <td>And</td><td>Day</td><td>Month</td><td>Year</td><td>DatePicker</td>
      </tr>
      <tr>
        <td></td>
        <td>
          <input type=text name="end_date_day" id="end_date_day" size="2" maxlength="2"/>
        </td>
        <td>
          <month-select name="end_date_month"/>
        </td>
        <td>
          <input type=text name="end_date_year" id="end_date_year" size="4" maxlength="4"/>
        </td>
        <td><input type="date"></td>
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
  }
</script>

/* 
   javascript for tasks/accessions/report/dwc
   */

var TW = TW || {};
TW.tasks = TW.tasks || {};
TW.tasks.accessions = TW.tasks.accessions || {};
TW.tasks.accessions.report = TW.tasks.accessions.report || {};
TW.tasks.accessions.report.dwc = TW.tasks.accessions.report.dwc || {};

Object.assign(TW.tasks.accessions.report.dwc, {

  init_dwc_report: function () {
    var tbl = $("#dwc_occurrence_table");
    if (tbl.length) {

      $(".dwc_row_stub").each(function() {
        var id = $(this).data('collectionObjectId');
       
        $.get('dwc/row/' + id, {}, function (local_data) {
          // $("#area_count").text(local_data.html);
          // $("#select_area").mx_spinner('hide');
        });

      });
    }
  }
} 
); // end widget

$(document).ready(TW.tasks.accessions.report.dwc.init_dwc_report);



// Returns todays date as a string in format of 'mm/dd/yyyy'
function get_todays_date(){
    let today = new Date();
    
    return convert_date_to_string(new Date());
}

// Returns a date obj as a string in format of 'mm/dd/yyyy'
function convert_date_to_string(dateObj){
    let mm = dateObj.getMonth() + 1;  // Jan is 0
    let dd = dateObj.getDate();
    let yyyy = dateObj.getFullYear();
    let date_string = "";

    if(mm < 10)
        date_string += "0";

    date_string += mm + "/";

    if(dd < 10)
        date_string += "0";

    date_string += dd + "/" + yyyy;

    return date_string;
}

function convert_date_to_string(date) {
    var time = new Date(date);
    return (time.getFullYear() + "/" + (time.getMonth() + 1)+ "/" + time.getDate());
}

function dateFormat(date, fmt) {
    var o = {
        "M+": date.getMonth() + 1,
        "d+": date.getDate(),
    };
    if (/(y+)/.test(fmt)) {
        fmt = fmt.replace(RegExp.$1, (date.getFullYear() + "").substr(4 - RegExp.$1.length));
    }
    for (var k in o) {
        if (new RegExp("(" + k + ")").test(fmt)) {
            fmt = fmt.replace(RegExp.$1, (RegExp.$1.length === 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
        }
    }
    return fmt;
}

// Checks if a date string is a valid date
function is_valid_date(date_string){
    let date = new Date(date_string);

    return !isNaN(date.getTime());
}
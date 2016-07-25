
// Returns todays date as a string in format of 'mm/dd/yyyy'
function get_todays_date(){
    let today = new Date();
    
    today.setHours(23, 59, 59, 999);

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

// Checks if a date string is a valid date
function is_valid_date(date_string){
    let date = new Date(date_string);

    return !isNaN(date.getTime());
}
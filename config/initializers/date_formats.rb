
Date::DATE_FORMATS[:file_timestamp] = '%Y_%m_%d_%H'
Date::DATE_FORMATS[:short_ordinal] = -> (date) { date.strftime("%B #{date.day.ordinalize}") }
# Contains methods used to build an interactive key
class InteractiveKey

  attr_accessor :observation_matrix_id

  attr_accessor :project_id

  attr_accessor :observation_matrix

  attr_accessor :descriptor_available_languages

  attr_accessor :descriptors

  def initialize(observation_matrix_id: nil, observation_matrix: nil, project_id: nil, descriptor_available_languages: nil)
    raise if observation_matrix_id.blank? || project_id.blank?
    @observation_matrix_id = observation_matrix_id
    @project_id = project_id
    @observation_matrix = observation_matrix
    @descriptor_available_languages = descriptor_available_languages
  end

  def observation_matrix
    ObservationMatrix.where(id: @observation_matrix_id, project_id: @project_id).first
  end

  def descriptors
    observation_matrix.descriptors
  end

  def descriptor_available_languages
    descriptor_ids = descriptors.pluck(:id)
    languages = Language.joins(:alternate_value_translations)
                    .where(alternate_values: {alternate_value_object_type: 'Descriptor', type: 'AlternateValue::Translation'})
                    .where('alternate_values.alternate_value_object_id IN (?)', descriptor_ids ).order('languages.english_name').distinct.to_a
    unless languages.empty?
      languages = Language.where(english_name: 'English').to_a + languages
    end
    languages
  end

end

=begin

strSQL = "SELECT Morph, Morph" & lng & " FROM Morph ORDER BY Morph"
Set rst1 = Server.CreateObject("ADODB.Recordset")
rst1.Open strSQL,Conn

<title>3I - Characters</title>
<link rel="stylesheet" href="style.css">
<link rel="meta" href="labels.rdf" type="application/rdf+xml" title="ICRA labels" />
</head>

<%
' Open recordset Set of all characters and states

if sex <> replace(sex, "e", "") then where = where & "Characters.Type Like '%e%' or "
if sex <> replace(sex, "l", "") then where = where & "Characters.Type Like '%l%' or "
if sex <> replace(sex, "p", "") then where = where & "Characters.Type Like '%p%' or "
if sex <> replace(sex, "n", "") then where = where & "Characters.Type Like '%n%' or "
if sex <> replace(sex, "m", "") then where = where & "Characters.Type Like '%m%' or "
if sex <> replace(sex, "f", "") then where = where & "Characters.Type Like '%f%' or "
if sex <> replace(sex, "d", "") then where = where & "Characters.Type Like '%d%' or "
if where & "" <> "" then where = "( " & left(where, len(where)-4) & ") and "
where = "WHERE " & where & "(Characters.Weight is Null or Characters.Weight Not Like '0') "
if keyN <> "" then where1 = "AND ','&Characters.KeyN&',' Like '%," & keyN & ",%' "

strSQL = "SELECT Characters.Key1, Characters.Char, Characters.Type, Characters.Numeric, Characters.Morph, Characters.Weight, Characters.Char" & lng & ", Characters.Descr" & lng & ", State.Key2, State.State, State.State" & lng & ", State.Fig " &_
	"FROM Characters INNER JOIN State ON Characters.Key1 = State.Key1 "
if cat = "1" then
	strSQL = strSQL & where & where1 & "ORDER BY Characters.Morph, Characters.Weight DESC, Characters.Char, State.State"
else
	strSQL = strSQL & where & where1 & "ORDER BY Characters.Weight DESC, Characters.Char, State.State"
end if
Set rst = Server.CreateObject("ADODB.Recordset")
rst.Open strSQL,Conn

' Fill out array taxa() with set of taxa

if keyN = "" then
	strSQL = "SELECT Key, Hiercode FROM TaxonQuery2 ORDER BY Hiercode"
else
	strSQL = "SELECT Key, Hiercode FROM TaxonQuery2 Where ','&KeyN&',' Like '%," & keyN & ",%' ORDER BY Hiercode"
end if
Set rst2 = Server.CreateObject("ADODB.Recordset")
rst2.Open strSQL, Conn

if rank = "" then
	Do Until rst2.EOF
		taxaMax = taxaMax + 1
		taxa(taxaMax, 0) = CStr(rst2("Key"))
		taxa(taxaMax, 1) = CStr(rst2("Hiercode"))
		if filter = "" or inStr(filter, "a" & rst2("Key") & "a") > 0 then
			taxa(taxaMax, 2) = "0"
		else
			taxa(taxaMax, 2) = "-1"
		end if
		rst2.MoveNext
	Loop
	rst2.Close
else
	Set rst4 = Server.CreateObject("ADODB.Recordset")
	strSQL = "SELECT Key, Hiercode, Rank FROM Taxon WHERE Rank>=" & rank & " ORDER BY Hiercode"
	rst4.Open strSQL, Conn, 3, 3
	Do Until rst2.EOF
		rst4.moveLast
		do until rst4("Hiercode") = left(rst2("Hiercode"), len(rst4("Hiercode")))
			rst4.movePrevious
		loop
		hc = rst4("Hiercode")
		i = rst4("Key")

		if hc > taxa(taxaMax, 1) then
			taxaMax = taxaMax + 1
			taxa(taxaMax, 0) = i
			taxa(taxaMax, 1) = hc
			if filter = "" or inStr(filter, "a" & i & "a") > 0 then
				taxa(taxaMax, 2) = "0"
			else
				taxa(taxaMax, 2) = "-1"
			end if
			taxa(taxaMax, 3) = "0"
		end if
		do until hc <> left(rst2("Hiercode"), len(hc))
			rst2.MoveNext
			if rst2.EOF then exit do
		loop
	Loop
	rst2.Close
	rst4.Close
	Set rst4 = Nothing
end if

' Save all used characters and their states into array charUsed()

CharMax = 0
Do Until rst.EOF
	i = CStr(rst("Char"))
	j = CStr(rst("State"))
	r = replace(CStr(Request("a" & i)), " ", "")
	r = replace(r, "aa", "a")
	if (r = j and multistates = "") or (rst("Numeric") = True and r <> "" and isNumeric(left(r, inStr(r & "-", "-") - 1)) and isNumeric(right(r, len(r) - inStr(r, "-")))) then
		charMax = charMax + 1
		charUsed(charMax, 1) = i
		charUsed(charMax, 2) = r
		charUsed(charMax, 3) = CStr(request("n" & i))
		if charUsed(charMax, 3) = "1" then
			states = states & "-" & rst("Key2")
		else
			states = states & rst("Key2")
		end if
		if rst("Numeric") = True then
			states = states & "-" & r & "b"
		else
			states = states & "b"
		end if
		where2 = where2 & " OR Char=" & i
	elseif multistates = "1" and rst("Numeric") = False then
		m = CStr(Request("m" & i))
		if (inStr(m, "!") = 0 and inStr(m, "a" & j & "a") > 0) or (m = "" and r = j) or (inStr(m, "!") = 1 and ((inStr(m, "a" & j & "a") > 0 and inStr(m, "a" & r & "a") > 0) or (r = j and inStr(m, "a" & r & "a") = 0))) then
			if charUsed(charMax, 1) <> i then charMax = charMax + 1
			charUsed(charMax, 1) = i
			charUsed(charMax, 2) = charUsed(charMax, 2) & "a" & j & "a"
			charUsed(charMax, 3) = CStr(request("n" & i))
			if charUsed(charMax, 3) = "1" then
				states = states & "-" & rst("Key2") & "b"
			else
				states = states & rst("Key2") & "b"
			end if
			where2 = where2 & " OR Char=" & i
		end if
	end if
	rst.moveNext
Loop
rst.MoveFirst
if where2 & "" <> "" then where2 = "AND (" & right(where2, len(where2) - 4) & ") "

' Open recordset Matrix of characters

if keyN <> "" then where1 = "AND ','&CharTableTotal.KeyN&',' Like '%," & keyN & ",%' AND ','&CharTableTotal.CharKeyN&',' Like '%," & keyN & ",%' "
strSQL = "SELECT Morph, Char, State, Hiercode, Numeric, NumericFrom, NumericTo FROM CharTableTotal "
if cat = "1" then
	strSQL = strSQL & replace(where, "Characters", "CharTableTotal") & where1 & where2 & "ORDER BY Morph, Weight DESC, Char, Hiercode, State"
else
	strSQL = strSQL & replace(where, "Characters", "CharTableTotal") & where1 & where2 & "ORDER BY Weight DESC, Char, Hiercode, State"
end if
rst2.Open strSQL, Conn


if rst2.eof then ' Datamatrix is empty
	response.write "<p style='color: #FF0000'>The datamatrix is empty!</p>"
else

' Mark the taxa in array taxa() which does not fit to criteria (count number of errors)

for j = 1 to charMax
	for i = 1 to taxaMax
	  if taxa(i, 2) <> "-1" then
	  	do until left(rst2("Hiercode"), len(taxa(i, 1))) = taxa(i, 1) and rst2("Char") & "" = charUsed(j, 1)
			rst2.MoveNext
		loop
		if multistates = "1" and rst2("Numeric") = False then
			if charUsed(j, 3) = "1" then ' character with not
				do until inStr(charUsed(j, 2), rst2("State")) = 0 or (rst2("State") & "" = "" and unknowns <> "1") or left(rst2("Hiercode"), len(taxa(i, 1))) <> taxa(i, 1)
					rst2.MoveNext
					if rst2.EOF then exit do
				loop
			else
				do until inStr(charUsed(j, 2), rst2("State")) > 0 or (rst2("State") & "" = "" and unknowns <> "1") or left(rst2("Hiercode"), len(taxa(i, 1))) <> taxa(i, 1)
					rst2.MoveNext
					if rst2.EOF then exit do
				loop
			end if
		else
			if charUsed(j, 3) = "1" then ' character with not
				do until (rst2("Numeric") = True and (rst2("NumericFrom") > cDbl(right(charUsed(j, 2), len(charUsed(j, 2)) - inStr(charUsed(j, 2), "-"))) or rst2("NumericTo") < cDbl(left(charUsed(j, 2), inStr(charUsed(j, 2) & "-", "-")-1)))) or (charUsed(j, 2) <> rst2("State") & "" and rst2("Numeric") = False) or (rst2("State") & "" = "" and unknowns <> "1") or left(rst2("Hiercode"), len(taxa(i, 1))) <> taxa(i, 1)
					rst2.MoveNext
					if rst2.EOF then exit do
				loop
			else
				do until (rst2("Numeric") = True and rst2("NumericFrom") <= cDbl(right(charUsed(j, 2), len(charUsed(j, 2)) - inStr(charUsed(j, 2), "-"))) and rst2("NumericTo") >= cDbl(left(charUsed(j, 2), inStr(charUsed(j, 2) & "-", "-")-1))) or (charUsed(j, 2) = rst2("State") & "" and rst2("Numeric") = False) or (rst2("State") & "" = "" and unknowns <> "1") or left(rst2("Hiercode"), len(taxa(i, 1))) <> taxa(i, 1)
					rst2.MoveNext
					if rst2.EOF then exit do
				loop
			end if
		end if
		if rst2.EOF then
			taxa(i, 2) = taxa(i, 2) + 1
		elseIf left(rst2("Hiercode"), len(taxa(i, 1))) <> taxa(i, 1) then
			taxa(i, 2) = taxa(i, 2) + 1
		end if
	  end if
	next
next

' Making query strings for lists of taxa

for t = 1 to taxaMax
	if CInt(taxa(t, 2)) <= tol and taxa(t, 2) <> "-1" then
		queryStr1 = queryStr1 & taxa(t, 0) & "a" & taxa(t, 2) & "a"
		if CInt(taxa(t, 2)) < tol then taxaRemTol = taxaRemTol + 1
		taxaRem = taxaRem + 1
	else
		queryStr2 = queryStr2 & taxa(t, 0) & "a" & taxa(t, 2) & "a"
	end if
next
if len(queryStr1) > 0 then queryStr1 = states & left(queryStr1, len(queryStr1) - 1)
if len(queryStr2) > 0 then queryStr2 = states & left(queryStr2, len(queryStr2) - 1)

' Resort recordset rst2

rst2.Close
strSQL = "SELECT Morph, Char, State, Hiercode, Numeric, NumericFrom, NumericTo " &_
	"FROM CharTableTotal "
if cat = "1" then
	strSQL = strSQL & replace(where, "Characters", "CharTableTotal") & where1 & "ORDER BY Morph, Weight DESC, Char, State, Hiercode"
else
	strSQL = strSQL & replace(where, "Characters", "CharTableTotal") & where1 & "ORDER BY Weight DESC, Char, State, Hiercode"
end if
rst2.Open strSQL, Conn

' Make the form with set of character

a = 1
t = 1
m = ""
j = rst("Char") & ""
Do Until rst.EOF
	if rank <> "" then
		for i = 1 to taxaMax
			taxa(i, 3) = "0"
		next
	end if
	i = rst("Char") & ""
	morphN = rst("Morph")
	charName = charReplace(rst("Char" & lng))

	descr = rst("Descr" & lng) & ""

	if not rst2.eof then
		Do Until rst2("Char") & "" = i
			rst2.MoveNext
			if rst2.EOF then exit do
		Loop
	end if

	if not rst2.eof then
	  fig = 0
	  weight = rst("Weight") & ""
	  CharTemp1 = ""
	  if weight <> "" then weight = ", I=" & weight
	  usefull = 0
	  stUnknown = 0
	  stNum = 0
	  stSum = 0
	  numMin = 9999999
	  numMax = -9999999

	  if rst("Numeric") = False then ' !!!!!!!!!!Not Numeric!!!!!!!!!
	  	if multistates = "1" then
	  		m = request("m" & i) & ""
	  		if (inStr(m, "!") = 1 and inStr(m, "a" & Request("a" & i) & "a") > 0) or (m <> "" and inStr(m, "!") <> 1) then
		  		m = Replace("<input type='hidden' name='m" & i & "' value='!" & Replace(m, "!", "") & "'>", "'!'", "''") & sp
			else
				m = "<input type='hidden' name='m" & i & "' value=''>" & sp
			end if
	  	end if
		if charUsed(a, 1) & "" <> i then
			CharTemp = "<li><b>" & charName & "</b> (" & UCase(rst("Type")) & weight & ")<br>" & sp & m & "not&nbsp;<input type=checkbox name='n" & i & "' value='1'>&nbsp;<select name='a" & i & "'>" & sp & "<option value='" & "' selected> </option>" & sp
		else
			CharTemp = "<li><b>" & charName & "</b> (" & UCase(rst("Type")) & weight & ")<br>" & sp & m & "not&nbsp;<input type=checkbox " & replace(charUsed(a,3), "1", "checked ") & "name='n" & i & "' value='1'>&nbsp;<select name='a" & i & "'>" & sp & "<option value='" & "'> </option>" & sp
		end if

		hc = 0
		if not rst2.eof then
			Do Until rst2("Char") & "" <> i or rst2("State") & "" <> ""
				z = 0
				Do Until left(rst2("Hiercode"), len(taxa(t, 1))) = taxa(t, 1)
					t = t + 1
					if t > taxaMax then
						t = 1
						z = z + 1
						if z > 1 then exit Do
					end if
				Loop
				if CInt(taxa(t, 2)) = tol and hc <> taxa(t, 1) and z < 2 then
					if rank <> "" then taxa(t, 3) = "1"
					stUnknown = stUnknown + 1
					hc = taxa(t, 1)
				end if
				rst2.MoveNext
				if rst2.eof then exit do
			Loop
		end if

		if unknowns = "1" then stUnknown = 0
		Do until j <> i
			stCount = stUnknown
			if not rst2.EOF then
				r = rst("State") & ""
				hc = 0
				Do Until rst2("Char") & "" <> i or rst2("State") & "" <> r
					z = 0
					Do Until left(rst2("Hiercode"), len(taxa(t, 1))) = taxa(t, 1)
						t = t + 1
						if t > taxaMax then
							t = 1
							z = z + 1
							if z > 1 then exit Do
						end if
					Loop
					if CInt(taxa(t, 2)) = tol and hc <> taxa(t, 1) and taxa (t, 3) <> "1" and z < 2 then
						stCount = stCount + 1
						hc = taxa(t, 1)
					end if
					rst2.MoveNext
					if rst2.EOF then Exit Do
				Loop
			end if
			stCount = stCount + taxaRemTol
			if stCount > 0 and stCount < taxaRem Then
				stNum = stNum + 1
				strCharArr(stNum, 0) = stCount
			end if

			if charUsed(a, 1) = i and (inStr(charUsed(a, 2) , "a" & r & "a") = 1 or charUsed(a, 2) = r) then
				CharTemp = CharTemp + "<option value='" & rst("State") & "' selected>&gt; " & charReplace(rst("State" & lng)) & "</option>" & sp
			elseif charUsed(a, 1) = i and inStr(charUsed(a, 2) & "", "a" & r & "a") > 1 then
				CharTemp = CharTemp + "<option value='" & rst("State") & "'>&gt; " & charReplace(rst("State" & lng)) & "</option>" & sp
			elseIf charUsed(a, 1) = i and charUsed(a, 2) <> r then
				CharTemp = CharTemp + "<option value='" & rst("State") & "'>" & charReplace(rst("State" & lng)) & "</option>" & sp
			else
				if stCount = 0 or stCount = taxaRem then
					CharTemp = CharTemp + "<option value='" & rst("State") & "'>- " & charReplace(rst("State" & lng)) & " ("&stCount&") -</option>" & sp
				else
					CharTemp = CharTemp + "<option value='" & rst("State") & "'>" & charReplace(rst("State" & lng)) & " ("&stCount&")</option>" & sp
					usefull = 1
				end if
				CharTemp1 = CharTemp1 & "&a" & rst("State") & "=" & stCount
			end if
			if rst("Fig") & "" <> "" then fig = 1

			rst.MoveNext
			if rst.EOF then
				exit do
			else
				j = rst("Char") & ""
			end if
		Loop
		CharTemp1 = CharTemp1 & "&b=" & taxaRem
		CharTemp = CharTemp + "</select>" & sp & sp
		If fig = 1 or descr <> "" or multistates = "1" then
			opt = len(CharTemp) - len(replace(CharTemp, "option", ""))
			if fig = 1 and multistates = "1" then opt = opt + 12
			if opt > 90 and fig = 1 then
				CharTemp = replace(CharTemp, ">" & charName & "<", "><a href=""" & "javascript:makeHelpWindow('" & i & CharTemp1 & "',800,600)""" & " Title='" & show & "'>" & charName & "</a><")
			elseIf opt > 50 or (multistates = "1" and fig = 1) then
				CharTemp = replace(CharTemp, ">" & charName & "<", "><a href=""" & "javascript:makeHelpWindow('" & i & CharTemp1 & "',640,480)""" & " Title='" & show & "'>" & charName & "</a><")
			elseIf opt < 50 then
				CharTemp = replace(CharTemp, ">" & charName & "<", "><a href=""" & "javascript:makeHelpWindow('" & i & CharTemp1 & "',640,300)""" & " Title='" & show & "'>" & charName & "</a><")
			end if
		end if

	  else ' !!!!!!!Numeric!!!!!!!!

		if not rst2.eof then
			hc = 0
			Do Until rst2("Char") & "" <> i or rst2("State") & "" <> ""
				z = 0
				Do Until left(rst2("Hiercode"), len(taxa(t, 1))) = taxa(t, 1)
					t = t + 1
					if t > taxaMax then
						t = 1
						z = z + 1
						if z > 1 then exit do
					end if
				Loop
				if CInt(taxa(t, 2)) = tol and hc <> taxa(t, 1) and z < 2 then
					if rank <> "" then taxa(t, 3) = "1"
					stUnknown = stUnknown + 1
					hc = taxa(t, 1)
				end if
				rst2.MoveNext
				if rst2.eof then exit do
			Loop
		end if

		usefull = 0
		if not rst2.eof then
			stCount = 0
			hc = 0
			do until rst2("Char") & "" <> i
				z = 0
				Do Until left(rst2("Hiercode"), len(taxa(t, 1))) = taxa(t, 1)
					t = t + 1
					if t > taxaMax then
						t = 1
						z = z + 1
						if z > 1 then exit Do
					end if
				Loop
				if CInt(taxa(t, 2)) = tol and z < 2 then
					if hc <> taxa(t, 1) and taxa(t, 3) <> "1" then
						hc = taxa(t, 1)
						stNum = stNum + 1
						strCharArr(stNum, 0) = rst2("NumericTo")
						strCharArr(stNum, 4) = rst2("NumericFrom")
					end if
					if strCharArr(stNum, 0) > rst2("NumericTo") then strCharArr(stNum, 0) = rst2("NumericTo")
					if strCharArr(stNum, 4) < rst2("NumericFrom") then strCharArr(stNum, 4) = rst2("NumericFrom")
					if numMin > rst2("NumericFrom") then
						if numMin < 9999999 then usefull = 1
						numMin = rst2("NumericFrom")
					end if
					if numMax < rst2("NumericTo") then
						if numMax > -9999999 then usefull = 1
						numMax = rst2("NumericTo")
					end if
					stCount = 1
				end if
				rst2.moveNext
				if rst2.eof then exit do
			loop
		end if
		if charUsed(a, 1) & "" <> i then
			if numMin = 9999999 then
				charTemp1 = ""
			elseIf numMin = numMax then
				charTemp1 = numMin & " "
			else
			CharTemp1 = numMin & "-" & numMax & " "
			end if
			CharTemp = "<li><b>" & charName & " [" & charTemp1 & charReplace(rst("State" & lng)) & "]</b> (" & UCase(rst("Type")) & weight & ")<br>" & sp & "not&nbsp;<input type=checkbox name='n" & i & "' value='1'>&nbsp;<input type='text' name='a" & i & "' value='' size='15'>" & sp
		else
			CharTemp = "<li><b>" & charName & " [" & charReplace(rst("State" & lng)) & "]</b> (" & UCase(rst("Type")) & weight & ")<br>" & sp & "not&nbsp;<input type=checkbox " & replace(charUsed(a,3), "1", "checked ") & "name='n" & i & "' value='1'>&nbsp;<input type='text' name='a" & i & "' value='" & charUsed(a, 2) & "' size='15'>" & sp
		end if
		If rst("fig") & "" <> "" or descr <> "" then
			CharTemp = replace(CharTemp, ">" & charName & " [" & charTemp1 & charReplace(rst("State" & lng)) & "]<", "><a href=""" & "javascript:makeHelpWindow('" & i & "',640,280)""" & " Title='" & show & "'>" & charName & "</a> [" & charTemp1 & charReplace(rst("State" & lng)) & "]<")
		end if

		rst.MoveNext
		if not rst.EOF then j = rst("Char") & ""

	  end if ' !!!!!!!!!Numeric!!!!!!!!!!
	end if

	if charUsed(a, 1) = i then
		strChar2 = strChar2 + CharTemp
		a = a + 1
	ElseIf usefull = 0 then
		strChar3 = strChar3 & CharTemp
	Else
		if taxaRem > 1 then
			if cat = "1" and rst1("Morph") <> morphN then
				Do until rst1("Morph") = morphN
					rst1.moveNext
				Loop
				morph = 0
			end if
			if cat = "1" and rst1("Morph") = morphN and morph <> 1 then
				l = Replace(rst1("Morph" & lng), " ", "&nbsp;")
				strChar1 = strChar1 & "<br><br><a name='" & l & "'></a><span class='a'>" & l & "</span><br><br>" & sp & sp
				link = link & "<a href='#" & l & "'>" & l & "</a>&nbsp;| " & sp
				morph = 1
			end if
			if cat <> "1" then
				if numMin = 9999999 then stMed = taxaRem / stNum else stMed = taxaRem
				For i1 = 1 to stNum
					if numMin = 9999999 then
						stSum = stSum + ((stMed) - strCharArr(i1, 0)) ^ 2
					else
						strCharArr(i1, 0) = strCharArr(i1, 4) - strCharArr(i1, 0)
						if strCharArr(i1, 0) = 0 then strCharArr(i1, 0) = (numMax - numMin) / 10
						stSum = stSum + strCharArr(i1, 0)
					end if
				Next
				strCharMax = strCharMax + 1
				if numMax = numMin then numMax = numMax + 0.00001
				if numMin = 9999999 then
					strCharArr(strCharMax, 2) = stMed + Sqr(stSum)
				else
					strCharArr(strCharMax, 2) = stMed * (stSum / stNum / (numMax - numMin)) * (2 - stNum / taxaRem)
				end if
				strCharArr(strCharMax, 1) = CharTemp ' & strCharArr(strCharMax, 2) '!!!!!!!!!!!!!!!!
				strCharArr(strCharMax, 3) = CLng("0" & replace(weight, ", I=", ""))
			else
				strChar1 = strChar1 & CharTemp
			end if
		else
			strChar3 = strChar3 & CharTemp
		End if
	End if
Loop

' Outputtin form

%>
<body>
<script type="text/javascript">
<!--
window.onerror = null;

if (window.parent.window.length != 4)
	{ window.location = ""; }
else {

window.parent.window.frames['taxa1'].window.document.forms['mainform'].elements['taxa'].value='<% =queryStr1 %>';
window.parent.window.frames['taxa1'].window.document.forms['mainform'].elements['lng'].value='<% =lng %>';
window.parent.window.frames['taxa1'].window.document.forms['mainform'].submit();
<% if tax = "1" then %>
	window.parent.window.frames['taxa2'].window.document.forms['mainform'].elements['taxa'].value='<% =queryStr2 %>';
	window.parent.window.frames['taxa2'].window.document.forms['mainform'].elements['lng'].value='<% =lng %>';
	window.parent.window.frames['taxa2'].window.document.forms['mainform'].submit();
<% end if %>
}
window.onfocus = ppHide;
var ww = null;

window.onclose = ppHide;

function makeHelpWindow(n,w,h)
{
if (navigator.appName == "Microsoft Internet Explorer")
<%
	Response.write "{ ww = window.open('charhelp.asp?key=" & key & "&lng=" & lng & "&m=" & multistates & "&keyN=" & keyN & "&ch=' + n,'_blank','scrollbars=" & scroll & ",resizable=no,width=' + w + ',height=' + h + ',top=' + (screen.availHeight - h) / 2 + ',left=' + (screen.availWidth - w) / 2 ); }"
%>
else
<%
	Response.write "{ ww = window.open('charhelp.asp?key=" & key & "&lng=" & lng & "&m=" & multistates & "&keyN=" & keyN & "&ch=' + n,'_blank','scrollbars=yes,resizable=yes,width=' + w + ',height=' + h + ',top=' + (screen.availHeight - h) / 2 + ',left=' + (screen.availWidth - w) / 2 ); }"
%>
}

function ppHide()
{ if(ww != null) ww.close(); ww=null;}

//-->
</script>

<%

if len(link) > 9 then
	link = left(link, len(link)-9)
end if %>

<form method='POST' action='char.asp' name='mainform'>

<input type="hidden" name="sex" value="<% =sex %>">
<input type="hidden" name="char" value="<% =char %>">
<input type="hidden" name="tax" value="<% =tax %>">
<input type="hidden" name="cat" value="<% =cat %>">
<input type="hidden" name="tol" value="<% =tol %>">
<input type="hidden" name="key" value="<% =key %>">
<input type="hidden" name="keyN" value="<% =keyN %>">
<input type="hidden" name="visit" value="<% =visit %>">
<input type="hidden" name="lng" value="<% =lng %>">
<input type="hidden" name="rank" value="<% =rank %>">
<input type="hidden" name="unknowns" value="<% =unknowns %>">
<input type="hidden" name="filter" value="<% =filter %>">
<input type="hidden" name="multistates" value="<% =multistates %>">
<%
if cat <> "1" and strCharMax > 1 then
For i = 1 to strCharMax - 1
For j = i + 1 to strCharMax
if strCharArr(i, 3) > strCharArr(j, 3) and cat = "0" then exit for
                                                               if strCharArr(i, 2) > strCharArr(j, 2) then
                                                                 CharTemp = strCharArr(i, 1)
                                                                 strCharArr(i, 1) = strCharArr(j, 1)
                                                                 strCharArr(j, 1) = CharTemp
                                                                 CharTemp = strCharArr(i, 2)
                                                                 strCharArr(i, 2) = strCharArr(j, 2)
                                                                 strCharArr(j, 2) = CharTemp
                                                               end if
      Next
  strChar1 = strChar1 + strCharArr(i, 1)
  Next
  strChar1 = strChar1 + strCharArr(strCharMax, 1)
  elseIf cat = "2" or strCharMax = 1 then
  strChar1 = strChar1 + strCharArr(1, 1)
                                                               end if
    if strChar2 & "" <> "" or filter <> "" then
      response.write "<div class='a'><ul>" & sp
      if strChar1 & "" <> "" then
        response.write "<li><a href='#useful'>" & rst3("Useful") & "</a>" & sp
        if len(link) > 0 then
          response.write "<br>" & sp & "(" & link & ")" & sp & sp
        end if
      end if
          if strChar3 & "" <> "" and char = "1" then
            response.write "<li><a href='#useless'>" & rst3("Relevant") & "</a>" & sp
          end if
          response.write "</ul></div>" & sp & sp
    end if


    if strChar2 & "" <> "" then
      response.Write sp & "<a Name='used'></a>" & sp & "<h2>" & rst3("Used") & "</h2>" & sp & sp
    end if
    if filter <> "" then
      if strChar2 & "" = "" then response.Write sp & "<a Name='used'></a>" & sp & "<h2>" & rst3("Used") & "</h2>" & sp & sp
      response.write "<p style='margin-bottom: 1em'><input type=checkbox checked name='f' value='1'>&nbsp;<b>Filter</b><br></p>" & sp & sp
      else
        response.write "<input type=hidden name='f' value=''>" & sp & sp
      end if
          if strChar2 & "" <> "" then
            response.write "<div class='a'><ol>" & sp & sp & strChar2 & "</ol></div>" & sp
          end if
          if strChar1 & "" <> "" then
            response.Write sp & "<a Name='useful'></a>" & sp & "<h2>" & rst3("Useful") & "</h2>" & sp & sp & "<p style='margin-bottom: 0em' align='center'>" & sp & link & sp & "</p>" & sp & sp & "<div class='a'><ol>" & sp & sp & strChar1 & "</ol></div>" & sp
          end if
          if strChar3 & "" <> "" and char = "1" then
            response.Write sp & "<a Name='useless'></a>" & sp & "<h2>" & rst3("Relevant") & "</h2>" & sp & sp & "<div class='a'><ol>" & sp & sp & strChar3 & "</ol></div>" & sp
          end if


          function charReplace(string)
      Do
      if inStr(string, "[") > 0 and inStr(string, "]") - inStr(string, "[") > 0 then
        string = trim(left(string, inStr(string, "[")-1) & right(string, len(string) - inStr(string, "]")))
      else
        Exit Do
      end if
          Loop
      string = replace(string & "", "{", "")
      string = replace(string, "}", "")
      string = replace(string, " & ", " &amp; ")
      if inStr(string & "<", "<") < inStrRev(">" & string, ">") and inStr(string, "</") > 0 then
      else
        string = replace(string, "<", "&lt;")
        string = replace(string, ">", "&gt;")
      end if
          charReplace = string
    end function

rst3.Close
Set rst3 = Nothing

end if ' Datamatrix is empty
=end

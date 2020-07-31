# Contains methods used to build an interactive key
class InteractiveKey

  # required attribude to build the key
  attr_accessor :observation_matrix_id

  #required attribute to build the key
  attr_accessor :project_id

  #returns ObservationMatrix object
  attr_accessor :observation_matrix

  #optional attribute to display the characters in a particular language
  attr_accessor :language_id

  #optional attribute to provide a list of tagIDs to limit the set of characters "1|5|15"
  attr_accessor :keyword_ids

  #optional attribute to provide a list of rowIDs to limit the set "1|5|10"
  attr_accessor :row_filter

  #optional attribute to sort the list of descriptors. Options: 'ordered', 'weighted', 'optimized', a default
  attr_accessor :sorting

  #optional attribute to eliminate taxa with not scored descriptors
  attr_accessor :eliminate_unknown

  #optional attribute number of allowed erros during identification
  attr_accessor :error_tolerance

  #limit identification to a particular nomenclatural rank 'genus', 'species', 'otu'
  attr_accessor :identified_to_rank

  #optional attribute: descriptors and states selected during identification
  attr_accessor :selected_descriptors



  #returns the list of Languages used as translations for descriptors
  attr_accessor :descriptor_available_languages

  #returns the list of all descriptors for this matrix
  attr_accessor :descriptors

  #returns the list of all Tags used with the descriptors
  attr_accessor :descriptor_available_keywords

  #the validated Language object to display descriptors in a particular language
  attr_accessor :language_to_use

  #list of descriptors reduced by keyword_ids
  attr_accessor :descriptors_with_filter

  #list of rows to be included into the matrix
  attr_accessor :rows_with_filter

  #return the list of descriptors with selections
  attr_accessor :used_descriptors

  #return the list of useful descriptors
  attr_accessor :useful_descriptors

  #return the list of descriptors not useful for identification
  attr_accessor :not_useful_descriptors

  #list of remaining rows
  attr_accessor :remaining

  #list of eliminated rows
  attr_accessor :eliminated

  def initialize(observation_matrix_id: nil, project_id: nil, language_id: nil, keyword_ids: nil, row_filter: nil, sorting: 'optimized', error_tolerance: 0, identified_to_rank: nil, eliminate_unknown: nil, selected_descriptors: nil)
    raise if observation_matrix_id.blank? || project_id.blank?
    @observation_matrix_id = observation_matrix_id
    @project_id = project_id
    @observation_matrix = observation_matrix
    @descriptor_available_languages = descriptor_available_languages
    @language_id = language_id
    @language_to_use = language_to_use
    @keyword_ids = keyword_ids
    @descriptor_available_keywords = descriptor_available_keywords
    @descriptors_with_filter = descriptors_with_keywords
    @row_filter = row_filter
    @rows_with_filter = rows_with_filter
    @sorting = sorting
    @error_tolerance = error_tolerance
    @eliminate_unknown = eliminate_unknown
    @identified_to_rank = identified_to_rank
    @selected_descriptors = selected_descriptors
    @used_descriptors ###
    @useful_descriptors ####
    @not_useful_descriptors ####
    @remaining ###
    @eliminated ###
  end

  def observation_matrix
    ObservationMatrix.where(id: @observation_matrix_id, project_id: @project_id).first
  end

  def descriptors
    if @sorting = 'weighted'
      observation_matrix.descriptors.where('NOT descriptors.weight = 0 OR descriptors.weight IS NULL').order('descriptors.weight DESC, descriptors.position')
    else
      observation_matrix.descriptors.where('NOT descriptors.weight = 0 OR descriptors.weight IS NULL').order(:position)
    end
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

  def language_to_use
    return nil if @language_id.blank?
    l = Language.where(id: @language_id).first
    return nil if l.nil? || !descriptor_available_languages.to_a.include?(l)
    l
  end

  def descriptor_available_keywords
    descriptor_ids = descriptors.pluck(:id)
    tags = Keyword.joins(:tags)
                    .where(tags: {tag_object_type: 'Descriptor'})
                    .where('tags.tag_object_id IN (?)', descriptor_ids ).order('name').distinct.to_a
  end

  def descriptors_with_keywords
    if @keyword_ids
      descriptors.joins(:tags).where('tags.keyword_id IN (?)', @keyword_ids.to_s.split('|') )
    else
      descriptors
    end
  end

  def rows
    observation_matrix.reorder_rows(by = 'nomenclature')
#    ObservationMatrixRow.where(observation_matrix_id: @observation_matrix_id)
  end

  def rows_with_filter
    if @row_item_filter
      rows
    else
      rows.where('observation_matrix_rows.id IN (?)', @row_filter.to_s.split('|'))
    end
  end

  def row_hash
    h = {}
    rows_with_filter.each do |r|
      h[r.id] = {}
      h[r.id][:object] = r
      if @identified_to_rank == 'otu'
        h[r.id][:object_at_rank] = r.current_otu || r
      elsif @identified_to_rank
        h[r.id][:object_at_rank] = r.current_taxon_name.ancestor_at_rank(@identified_to_rank, inlude_self = true) || r
      else
        h[r.id][:object_at_rank] = r
      end
      h[r.id][:errors] = 0
    end
    h
  end

  def descriptors_hash
    h = {}
    descriptors_with_keywords.each do |d|
      h[d.id] = {}
      h[d.id][:descriptor] = d
      h[d.id][:states] = {}
      h[d.id][:observations] = {}
    end
    @observation_matrix.observations.each do |o|
      if h[o.descriptor_id]
        h[o.descriptor_id][:observations][o.otu_id.to_s + '|' + o.collection_object_id.to_s] = [] if h[o.descriptor_id][:observations][o.otu_id.to_s + '|' + o.collection_object_id.to_s].nil?
        h[o.descriptor_id][:observations][o.otu_id.to_s + '|' + o.collection_object_id.to_s] += [o]
        h[o.descriptor_id][:states][o.character_state_id] = {} if o.character_state_id
      end
    end
    h
  end


  def observations
    # id
    # descriptor_id
    # otu_id
    # collection_object_id
    # character_state_id
    # continuous_value
    # continuous_unit
    # sample_min
    # sample_max
    # sample_unit
    # presence
    # description
    # cached
    # cached_column_label
    # cached_row_label
    # description
    # type
    ### types: Qualitative(char_states); Presence absence; Quantitative (single measurement); Sample (min, max); Free text
  end


=begin
  not numeric
  weight = rem_taxa/number_of_states + squer (sum (rem_taxa/number_of_states - taxa_in_each_state)^2)

  numeric for each measurement for a particular species
                                 i = max - min ; if 0 then (numMax - numMin) / 10
                                 sum of all i
                                 if numMax = numMin then numMax = numMax + 0.00001
                                 weight = rem_taxa * (sum of i / number of measuments for taxon / (numMax - numMin) ) * (2 - number of measuments for taxon / rem_taxa)
=end

                                                                                                                                                    # rst = All characters ordered by Characters.Weight DESC, Characters.Char, State.State"
  # rst2 = List of all taxa from the key ordered by hiercode
  # filter = taxa with specic IDs
  # list of used states
  # count the number of errors for each taxon
end

=begin


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

module Plugins::PapertrailHelper

  def paper_trail_version_tag(paper_trail_version)
    return nil if paper_trail_version.nil?
    "Revision #{paper_trail_version.index}" 
  end

  def papertrail_link_tag(object)
    content_tag(:li, link_to('Papertrail', papertrail_path(object_type: object.metamorphosize.class, object_id: object.id))) if object.respond_to?(:versions) 
  end

=begin

  Snipped from @merfoo's helper

  Let curr_index_new and curr_index_old loop from 0 to new string length and old string length respectively
    if curr_index_new < new strings length and curr_index_old < old string length
      if characters from both strings at their respective indexes match
        increase both index by 1
        continue to next iteration
      else if characters from both strings dont match
        Let new_index_new = curr_index_new
        Let new_index_old loop from curr_index_old to old string length
          if new_index_new > new string length
            add rest of new string to added strings and add rest of old string to deleted strings
            break out of loop
          if character of old string at newOldIndex == character of new string at new_index_new
            if (new_index_new - curr_index_new) > 0
              add substring of new string from curr_index_new to new_index_new to added strings
            if (newOldIndex - currOldIndex) > 0
              add substring of old string from curr_index_old to new_index_old to deleted strings
          if new_index_old > old string length
            set new_index_old to curr_index_old
            increase new_index_new by 1
    else if either of curr_index_new or curr_index_old > their respective strings
      if curr_index_new < new string
        add rest of new string to added strings
      else if curr_index_old < old string length
        add rest of old string to deleted strings
=end

  def get_diffs version_new, version_old
    added_strings = []
    added_strings_indices = []
    deleted_strings = []
    deleted_strings_indices = []

    curr_index_new = 0
    curr_index_old = 0

    while curr_index_new < version_new.length || curr_index_old < version_old.length
      if curr_index_new < version_new.length && curr_index_old < version_old.length
        if version_new[curr_index_new] == version_old[curr_index_old]
          curr_index_new += 1
          curr_index_old += 1
        else
          new_index_new = curr_index_new
          new_index_old = curr_index_old

          while new_index_old < version_old.length
            if new_index_new > version_new.length || version_old[new_index_old] == version_new[new_index_new]
              if curr_index_new != new_index_new
                added_strings.push(version_new[curr_index_new...new_index_new])
                added_strings_indices.push(curr_index_new)
              end

              if curr_index_old != new_index_old
                deleted_strings.push(version_old[curr_index_old...new_index_old])
                deleted_strings_indices.push(curr_index_old)
              end

              curr_index_new = new_index_new
              curr_index_old = new_index_old
              break
            elsif new_index_old == version_old.length - 1
              new_index_old = curr_index_old;
              new_index_new += 1 
              next
            end

            new_index_old += 1;
          end
        end
      else
        if curr_index_new < version_new.length
          added_strings.push(version_new[curr_index_new...version_new.length])
          added_strings_indices.push(curr_index_new)
        elsif curr_index_old < version_old.length
          deleted_strings.push(version_old[curr_index_old...version_old.length])
          deleted_strings_indices.push(curr_index_old)
        end

        break
      end
    end

    return {
      'added_strings' => added_strings,
      'added_strings_indices' => added_strings_indices, 
      'deleted_strings' => deleted_strings,
      'deleted_strings_indices' => deleted_strings_indices
    }
  end

  # For getting diffs between strings where the length are the same for each
  def get_diffs_date version_new, version_old
    added_strings = []
    added_strings_indices = []
    deleted_strings = []
    deleted_strings_indices = []

    start_index = 0
    end_index = 0
    found_mismatch = false

    for end_index in 0...version_new.length
      if version_new[end_index] == version_old[end_index]
        if found_mismatch
          found_mismatch = false
          added_strings.push(version_new[start_index...end_index])
          deleted_strings.push(version_old[start_index...end_index])
          added_strings_indices.push(start_index)
          deleted_strings_indices.push(start_index)
        end
      else
        if !found_mismatch
          found_mismatch = true
          start_index = end_index
        end
      end
    end

    return {
      'added_strings' => added_strings,
      'added_strings_indices' => added_strings_indices, 
      'deleted_strings' => deleted_strings,
      'deleted_strings_indices' => deleted_strings_indices
    }
  end

  # Returns an html string of <p> where a <p> is given the class of 
  # style_class if it is in the highlighted_words array
  def get_highlighted_words words, highlighted_words, highlighted_words_indices, style_class
    start_index = 0
    end_index = 0
    html_string = ''

    for highlighted_index in 0...highlighted_words_indices.length
      while end_index < highlighted_words_indices[highlighted_index]
        end_index += 1
      end
      
      if start_index != end_index
        html_string += '<span>'
        html_string += words[start_index...end_index]
        html_string += '</span>'
      end    

      start_index = end_index
      end_index += highlighted_words[highlighted_index].length

      html_string += "<span class=\"#{style_class}\">"
      html_string += words[start_index...end_index]
      html_string += '</span>'

      start_index = end_index
    end

    if end_index < words.length
      html_string += '<span>'
      html_string += words[end_index...words.length]
      html_string += '</span>'
    end

    return html_string.html_safe
  end

  # Returns a hash of all the unique authors for a papertrail obj
  # hash key is the author email, hash value is the author name
  def get_unique_authors version_list
    unique_authors = {}

    # Iterate over each version
    version_list.each do |version|
      version_author = User.find(version.whodunnit)

      # If the current version author email is not present in the
      # unique_authors hash, add it
      if !unique_authors.key?(version_author.email)
        unique_authors[version_author.email] = version_author.name
      end
    end

    return unique_authors
  end

  # Returns a new hash of attributes that doesn't have unwanted
  # key/value pair in them, currently filters out hashes with keys of
  # "id"
  # "created_at"
  # "created_by_id"
  # "updated_by_id"
  # "project_id"
  def filter_out_attributes(attributes)
    attributes_filter = ['id', 'created_at', 'created_by_id', 'updated_by_id', 'project_id']
    filtered_attributes = {}

    # Make the "updated_at" attribute the first hash for formatting purposes
    filtered_attributes['updated_at'] = 0

    attributes.each do |key, value|
      if !attributes_filter.include?(key)
        filtered_attributes[key] = value
      end
    end

    return filtered_attributes
  end


end

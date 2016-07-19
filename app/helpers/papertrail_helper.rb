module PapertrailHelper

=begin
    Let currIndexNew and currIndexOld loop from 0 to new string length and old string length respectively
        if currIndexNew < new strings length and currIndexOld < old string length
            if characters from both strings at their respective indexes match
                increase both index by 1
                continue to next iteration
            else if characters from both strings dont match
                Let newIndexNew = currIndexNew
                Let newIndexOld loop from currIndexOld to old string length
                    if newIndexNew > new string length
                        add rest of new string to added strings and add rest of old string to deleted strings
                        break out of loop
                    if character of old string at newOldIndex == character of new string at newIndexNew
                        if (newIndexNew - currIndexNew) > 0
                            add substring of new string from currIndexNew to newIndexNew to added strings
                        if (newOldIndex - currOldIndex) > 0
                            add substring of old string from currIndexOld to newIndexOld to deleted strings
                    if newIndexOld > old string length
                        set newIndexOld to currIndexOld
                        increase newIndexNew by 1
        else if either of currIndexNew or currIndexOld > their respective strings
            if currIndexNew < new string
                add rest of new string to added strings
            else if currIndexOld < old string length
                add rest of old string to deleted strings
=end

    def get_diffs version_new, version_old
        added_strings = []
        added_strings_indices = [];
        deleted_strings = []
        deleted_strings_indices = [];

        currIndexNew = 0
        currIndexOld = 0

        while currIndexNew < version_new.length || currIndexOld < version_old.length
            if currIndexNew < version_new.length && currIndexOld < version_old.length
                if version_new[currIndexNew] == version_old[currIndexOld]
                    currIndexNew += 1
                    currIndexOld += 1
                else
                    newIndexNew = currIndexNew
                    newIndexOld = currIndexOld

                    while newIndexOld < version_old.length
                        if newIndexNew > version_new.length || version_old[newIndexOld] == version_new[newIndexNew]
                            if currIndexNew != newIndexNew
                                added_strings.push(version_new[currIndexNew...newIndexNew])
                                added_strings_indices.push(currIndexNew)
                            end

                            if currIndexOld != newIndexOld
                                deleted_strings.push(version_old[currIndexOld...newIndexOld])
                                deleted_strings_indices.push(currIndexOld)
                            end

                            currIndexNew = newIndexNew
                            currIndexOld = newIndexOld
                            break
                        elsif newIndexOld == version_old.length - 1
                            newIndexOld = currIndexOld;
                            newIndexNew += 1 
                            next
                        end

                        newIndexOld += 1;
                    end
                end
            else
                if currIndexNew < version_new.length
                    added_strings.push(version_new[currIndexNew...version_new.length])
                    added_strings_indices.push(currIndexNew)
                elsif currIndexOld < version_old.length
                    deleted_strings.push(version_old[currIndexOld...version_old.length])
                    deleted_strings_indices.push(currIndexOld)
                end

                break
            end
        end

        return {
            "added_strings" => added_strings,
            "added_strings_indices" => added_strings_indices, 
            "deleted_strings" => deleted_strings,
            "deleted_strings_indices" => deleted_strings_indices
        }
    end
end